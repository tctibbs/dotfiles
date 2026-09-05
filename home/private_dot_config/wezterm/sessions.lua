-- Remember which directories you had open.
--
-- Not session restore. Programs are not saved, restarted or resurrected — the
-- only thing persisted is the working directory of each tab, plus enough
-- structure to put them back in the same windows.
--
-- That is deliberately the smallest useful thing. Directories are the part
-- that survives a reboot meaningfully: land back in the project and resume the
-- agent yourself (`claude -c`, `codex resume`). It also needs no per-agent
-- knowledge, so it does not rot when an agent changes its CLI.
--
-- Workspaces are out of scope. WezTerm renders one workspace at a time, so a
-- window restored into a saved, non-active workspace exists but is invisible —
-- indistinguishable from a restore that failed. Everything comes back in the
-- active workspace.
--
-- State lives in WezTerm's data directory, not the config, because it is
-- machine state rather than configuration and must not be committed.

local wezterm = require("wezterm")
local text = require("text")

local module = {}

local STATE_DIR = wezterm.home_dir .. "/.local/share/wezterm"
local STATE_PATH = STATE_DIR .. "/tabs.json"

-- Each GUI process writes its own temporary file, in the same directory as the
-- target so the rename stays atomic. A shared temp path lets two instances
-- interleave their writes and rename a mixture into place. Lua 5.4 seeds
-- math.random per process, so this differs between GUI instances.
--
-- The state file itself is still last-writer-wins across instances: a snapshot
-- only sees its own process's windows. Saving from several instances at once
-- keeps whichever wrote last, which is the intended behaviour rather than a
-- merge — merging would resurrect windows the user deliberately closed.
local TMP_PATH = string.format("%s.%d.tmp", STATE_PATH, math.random(100000, 999999))

-- Warn once rather than on every save cycle.
local warned = false
local function warn_once(message)
    if not warned then
        warned = true
        wezterm.log_warn("sessions: " .. message)
    end
end

-- Saving periodically rather than on quit: a quit hook misses a crash, a panic
-- or a held power button, which are exactly the cases this exists for.
--
-- The clock is WezTerm's own update-status event, throttled here. An earlier
-- version re-armed wezterm.time.call_after from inside its own callback, which
-- fires exactly once and never reschedules — the state file then froze at the
-- startup snapshot. update-status is driven by WezTerm and fires reliably;
-- registering a second handler does not disturb the one in status.lua.
local SAVE_INTERVAL_SECONDS = 120

-- A runaway or hand-edited state file should not be able to spawn hundreds of
-- tabs at startup.
local MAX_WINDOWS = 8
local MAX_TABS_PER_WINDOW = 24

--- Working directory of a pane as a plain path.
-- get_current_working_dir returns a Url object; older releases returned a
-- string, so both are handled.
local function pane_cwd(pane)
    local ok, cwd = pcall(function()
        return pane:get_current_working_dir()
    end)
    if not ok or not cwd then
        return nil
    end

    if type(cwd) == "string" then
        return (cwd:gsub("^file://[^/]*", ""))
    end

    local got, path = pcall(function()
        return cwd.file_path
    end)
    if got and type(path) == "string" and path ~= "" then
        return path
    end
    return nil
end

--- Label for a restored tab: the project directory's name.
-- Home is shown as "~" rather than the account name, which is what the last
-- path segment would otherwise give.
local function label_for(path)
    if type(path) ~= "string" or path == "" then
        return ""
    end
    if path == wezterm.home_dir then
        return "~"
    end
    return (path:gsub("/+$", ""):gsub(".*/", ""))
end

--- Current windows and the directory of each tab's active pane.
local function snapshot()
    local windows = {}

    for _, mux_window in ipairs(wezterm.mux.all_windows()) do
        local tabs = {}

        local listed, mux_tabs = pcall(function()
            return mux_window:tabs()
        end)

        for _, tab in ipairs(listed and mux_tabs or {}) do
            local pane = tab:active_pane()
            local cwd = pane and pane_cwd(pane)
            if cwd then
                tabs[#tabs + 1] = { cwd = cwd }
            end
        end

        if #tabs > 0 then
            windows[#windows + 1] = { tabs = tabs }
        end
    end

    return { version = 1, windows = windows }
end

--- Write the state file, replacing it atomically.
-- A partial write during a crash would leave unparseable JSON exactly when it
-- is needed, so the new file is written alongside and renamed into place.
local function save()
    local ok, state = pcall(snapshot)
    if not ok or #state.windows == 0 then
        return
    end

    local encoded
    ok, encoded = pcall(wezterm.json_encode, state)
    if not ok then
        return
    end

    local file, open_err = io.open(TMP_PATH, "w")
    if not file then
        warn_once("cannot write " .. TMP_PATH .. ": " .. tostring(open_err)
            .. " (does " .. STATE_DIR .. " exist?)")
        return
    end

    -- A short write or a failed flush would otherwise be renamed over the good
    -- state, which is exactly what writing alongside and renaming prevents.
    local wrote, write_err = file:write(encoded)
    local closed, close_err = file:close()

    if not wrote or not closed then
        warn_once("failed writing state: " .. tostring(write_err or close_err))
        os.remove(TMP_PATH)
        return
    end

    os.rename(TMP_PATH, STATE_PATH)
end

--- Read the state file and return only entries that are safe to restore.
--
-- The file is untrusted: it can be hand-edited, truncated by a crash, or left
-- behind by a future schema. Validating only the top-level shape is not
-- enough — a well-formed `{"windows":[{"tabs":[{}]}]}` would pass and then
-- blow up mid-restore on the missing cwd, aborting the whole gui-startup
-- handler and losing every remaining window. Everything is checked here, so
-- restore can assume each cwd is a non-empty string.
--
-- @return table|nil list of windows, each { tabs = { { cwd = string }, ... } }
local function load()
    local file = io.open(STATE_PATH, "r")
    if not file then
        return nil
    end

    local raw = file:read("*a")
    file:close()
    if not raw or raw == "" then
        return nil
    end

    local ok, state = pcall(wezterm.json_parse, raw)
    if not ok or type(state) ~= "table" or type(state.windows) ~= "table" then
        return nil
    end

    local windows = {}
    for _, saved in ipairs(state.windows) do
        if type(saved) == "table" and type(saved.tabs) == "table" then
            local tabs = {}
            for _, tab in ipairs(saved.tabs) do
                if type(tab) == "table" and type(tab.cwd) == "string" and tab.cwd ~= "" then
                    tabs[#tabs + 1] = { cwd = tab.cwd }
                end
            end
            if #tabs > 0 then
                windows[#windows + 1] = { tabs = tabs }
            end
        end
    end

    if #windows == 0 then
        return nil
    end
    return windows
end

--- Open one window and its tabs, each in its saved directory.
-- A directory that no longer exists falls back to home rather than aborting
-- the whole restore; projects get deleted and startup must still work.
local function restore_window(saved)
    local tabs = saved.tabs or {}
    if #tabs == 0 then
        return false
    end

    local function spawn_window(cwd)
        local ok, _, _, win = pcall(function()
            return wezterm.mux.spawn_window({ cwd = cwd })
        end)
        return ok and win or nil
    end

    local window = spawn_window(tabs[1].cwd) or spawn_window(wezterm.home_dir)
    if not window then
        return false
    end

    local function name(tab, cwd)
        local label = text.sanitize(label_for(cwd))
        if tab and label ~= "" then
            pcall(function()
                tab:set_title(label)
            end)
        end
    end

    name(window:active_tab(), tabs[1].cwd)

    for i = 2, math.min(#tabs, MAX_TABS_PER_WINDOW) do
        local cwd = tabs[i].cwd
        local ok, tab = pcall(function()
            return window:spawn_tab({ cwd = cwd })
        end)
        if not ok or not tab then
            ok, tab = pcall(function()
                return window:spawn_tab({})
            end)
        end
        if ok and tab then
            name(tab, cwd)
        end
    end

    return true
end

function module.apply(config)
    local last_save = 0

    wezterm.on("update-status", function()
        local now = os.time()
        if now - last_save < SAVE_INTERVAL_SECONDS then
            return
        end
        last_save = now
        pcall(save)
    end)

    wezterm.on("gui-startup", function(cmd)
        -- An explicit command means the user asked for something specific;
        -- honour it and leave the saved directories alone.
        if cmd then
            wezterm.mux.spawn_window(cmd)
            return
        end

        local restored = 0

        for i, saved in ipairs(load() or {}) do
            if i > MAX_WINDOWS then
                break
            end
            -- Defence in depth: this handler owns spawning the first window,
            -- so one unexpected error here must not cost the user every tab.
            local ok, did = pcall(restore_window, saved)
            if ok and did then
                restored = restored + 1
            elseif not ok then
                warn_once("restore failed: " .. tostring(did))
            end
        end

        -- Nothing to restore, or every restore failed: this handler owns
        -- spawning, so a window has to come from somewhere.
        if restored == 0 then
            wezterm.mux.spawn_window({})
        end
    end)
end

return module
