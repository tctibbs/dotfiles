-- Right status: a one-line rollup of every agent in the window.
--
-- The tab bar answers "what is this tab doing". This answers "is anything
-- waiting on me" without reading the tabs at all, which is the question you
-- actually have when several agents are running.
--
-- Identity comes from agents.identify and the state vocabulary from
-- agents.state, the same sources the tab bar uses, so the rollup and the tabs
-- cannot disagree about which panes are agents or what a state is called.

local wezterm = require("wezterm")
local p = require("palette")
local agents = require("agents")
local agent_state = require("agents.state")

local nf = wezterm.nerdfonts
local module = {}

-- Rendered left to right, most urgent first; zero counts are omitted.
local ORDER = {
    { state = "waiting", glyph = nf.md_alert_circle },
    { state = "working", glyph = nf.md_progress_clock },
    { state = "idle", glyph = nf.md_check_circle },
}

--- Call a method on a live mux object, tolerating its disappearance.
-- These are live handles; a pane or tab can close between enumeration and
-- access, and a missing method must degrade rather than abort the status bar.
local function try(obj, method)
    local ok, value = pcall(function()
        return obj[method](obj)
    end)
    if ok then
        return value
    end
    return nil
end

--- Read a tab's active pane into the shape agents.identify expects.
-- Title precedence matches tabs/init.lua: an explicitly set tab title wins
-- over the pane title, so title-pattern identity resolves the same way here.
local function read_tab(tab, pane)
    local title = try(tab, "get_title")
    if type(title) ~= "string" or title == "" then
        title = try(pane, "get_title")
    end

    return {
        user_vars = try(pane, "get_user_vars"),
        process = try(pane, "get_foreground_process_name"),
        title = title,
    }
end

--- Count agent states across the window, one entry per tab.
--
-- Scope deliberately mirrors the tab bar: one active pane per tab, identified
-- the same way, with the same unseen-output inference. Counting every pane
-- instead would report agents that no tab is showing.
--
-- @return table counts keyed by canonical state
-- @return number how many agent tabs were found at all
local function tally(window)
    local counts = { working = 0, idle = 0, waiting = 0 }
    local total = 0

    local mux_window = try(window, "mux_window")
    if not mux_window then
        return counts, total
    end

    local tabs = try(mux_window, "tabs")
    if not tabs then
        return counts, total
    end

    -- If the active tab cannot be determined, no tab can be proven unfocused,
    -- so the unseen-output inference is skipped entirely below. Comparing
    -- against a nil id would instead mark every tab unfocused and let the
    -- focused one be counted as needing attention, which the tab bar never
    -- does.
    local active = try(mux_window, "active_tab")
    local active_id = active and try(active, "tab_id")

    for _, tab in ipairs(tabs) do
        local pane = try(tab, "active_pane")
        if pane then
            local src = read_tab(tab, pane)
            local agent, method = agents.identify(src)
            if agent then
                total = total + 1

                local vars = type(src.user_vars) == "table" and src.user_vars or {}
                local state = agent_state.normalize(vars.agent_state)

                -- Same rules as the tab bar: only a trusted identity earns a
                -- state, and an unfocused agent tab with unseen output on its
                -- active pane is treated as wanting attention.
                if not agents.is_trusted(method) then
                    state = nil
                elseif not state
                    and active_id ~= nil
                    and try(tab, "tab_id") ~= active_id
                    and try(pane, "has_unseen_output") then
                    state = "waiting"
                end

                if state and counts[state] then
                    counts[state] = counts[state] + 1
                end
            end
        end
    end

    return counts, total
end

function module.apply(config)
    -- A user-var write already triggers a title update, which re-runs this
    -- event, so the interval only bounds how stale a process-detected agent
    -- can look. There is no reason to poll faster than a human reacts.
    config.status_update_interval = 2000

    wezterm.on("update-status", function(window, _pane)
        local counts, total = tally(window)

        local cells = {}
        if total > 0 then
            for _, entry in ipairs(ORDER) do
                local n = counts[entry.state]
                if n > 0 then
                    local def = agent_state.states[entry.state]
                    cells[#cells + 1] = { Foreground = { Color = def.color } }
                    cells[#cells + 1] = { Text = " " .. entry.glyph .. " " .. tostring(n) }
                end
            end
        end

        if #cells == 0 then
            window:set_right_status("")
            return
        end

        cells[#cells + 1] = { Foreground = { Color = p.surface2 } }
        cells[#cells + 1] = { Text = "  " }

        window:set_right_status(wezterm.format(cells))
    end)
end

return module
