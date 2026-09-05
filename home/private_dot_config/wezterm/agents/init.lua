-- Coding agent registry
--
-- Each agent is defined in its own file under agents/ and returns a table
-- matching the contract below. To add an agent: drop in agents/<id>.lua and
-- add its id to REGISTERED.
--
-- Contract
-- --------
--   id              string   required  unique; must equal the value written to
--                                      the `agent_id` user var by the
--                                      wezterm-agent-state helper
--   name            string   required  human-readable label, used in docs/errors
--   icon            string   required  Nerd Font glyph
--   color           string   required  hex accent shown when this agent is active
--   processes       table    optional  foreground process names to match
--   title_patterns  table    optional  lowercase Lua patterns matched on the
--                                      pane title
--
-- Detection precedence, highest confidence first:
--   1. `agent_id` user var  — exact, survives any title the agent sets
--   2. processes            — reliable, but many agents run as `node`
--   3. title_patterns       — last resort; agents that set an LLM-generated
--                             title will not match. See docs/wezterm.md.
--
-- A malformed agent file is skipped with a logged warning rather than taking
-- the whole tab bar down with it.

local wezterm = require("wezterm")

local module = {}

local REGISTERED = {
    "claude",
    "codex",
    "copilot",
    "antigravity",
}

local REQUIRED_FIELDS = { "id", "name", "icon", "color" }

--- Validate an agent definition against the contract.
-- @return boolean ok
-- @return string|nil error message
local function validate(def, source)
    if type(def) ~= "table" then
        return false, source .. " did not return a table"
    end

    for _, field in ipairs(REQUIRED_FIELDS) do
        if type(def[field]) ~= "string" or def[field] == "" then
            return false, source .. " is missing required string field '" .. field .. "'"
        end
    end

    for _, field in ipairs({ "processes", "title_patterns" }) do
        if def[field] ~= nil and type(def[field]) ~= "table" then
            return false, source .. " field '" .. field .. "' must be a table"
        end
    end

    return true
end

-- Load once at config evaluation. Keyed by id for user-var lookups, and kept
-- as an ordered list so detection is deterministic.
local by_id = {}
local ordered = {}

for _, id in ipairs(REGISTERED) do
    local source = "agents/" .. id .. ".lua"
    local ok, def = pcall(require, "agents." .. id)

    if not ok then
        wezterm.log_warn("agents: could not load " .. source .. ": " .. tostring(def))
    else
        local valid, err = validate(def, source)
        if not valid then
            wezterm.log_warn("agents: ignoring " .. source .. ": " .. err)
        elseif by_id[def.id] then
            wezterm.log_warn("agents: duplicate id '" .. def.id .. "' in " .. source)
        else
            by_id[def.id] = def
            table.insert(ordered, def)
        end
    end
end

module.by_id = by_id
module.all = ordered

--- Look up an agent by its registered id.
function module.get(id)
    return id and by_id[id] or nil
end

--- Bare executable name from a path, without a Windows extension.
-- `processes` entries are bare lowercase names, so claude.exe must reduce to
-- "claude" or nothing matches on Windows.
local function basename(path)
    if type(path) ~= "string" or path == "" then
        return nil
    end
    local name = path:gsub("(.*[/\\])(.*)", "%2"):lower()
    return (name:gsub("%.exe$", ""))
end

--- Which detection methods are strong enough to act on.
-- A title match is a guess: any program can print a title containing an agent
-- name. It is good enough to pick an icon, but not to escalate a whole tab.
local TRUSTED = { user_var = true, process = true }

--- Is this detection method strong enough to drive state?
function module.is_trusted(method)
    return TRUSTED[method or ""] == true
end

--- Identify an agent from primitive inputs.
--
-- Deliberately takes plain values rather than a TabInformation, so the tab bar
-- and the status rollup can share one definition of "which agent is this".
-- They walk different object graphs (TabInformation vs MuxPane) and would
-- otherwise drift apart, disagreeing about the same pane.
--
-- @param src table { user_vars = table|nil, process = string|nil, title = string|nil }
-- @return table|nil agent definition
-- @return string|nil detection method: "user_var" | "process" | "title"
function module.identify(src)
    src = src or {}

    -- 1. Explicitly reported by the agent itself.
    local vars = src.user_vars
    if type(vars) == "table" then
        local agent = by_id[vars.agent_id or ""]
        if agent then
            return agent, "user_var"
        end
    end

    -- 2. Foreground process name.
    local exe = basename(src.process)
    if exe then
        for _, agent in ipairs(ordered) do
            for _, candidate in ipairs(agent.processes or {}) do
                if exe == candidate then
                    return agent, "process"
                end
            end
        end
    end

    -- 3. Title text. Fragile by nature — kept last. Patterns come from agent
    -- files, so a malformed one is contained rather than aborting the caller.
    if type(src.title) == "string" and src.title ~= "" then
        local haystack = src.title:lower()
        for _, agent in ipairs(ordered) do
            for _, pattern in ipairs(agent.title_patterns or {}) do
                local ok, found = pcall(string.find, haystack, pattern)
                if ok and found then
                    return agent, "title"
                end
            end
        end
    end

    return nil
end

--- Identify the agent running in a tab.
-- @param tab TabInformation
-- @return table|nil agent definition
-- @return string|nil detection method
function module.detect(tab)
    local pane = tab and tab.active_pane
    if not pane then
        return nil
    end

    local title = tab.tab_title
    if not title or title == "" then
        title = pane.title
    end

    return module.identify({
        user_vars = pane.user_vars,
        process = pane.foreground_process_name,
        title = title,
    })
end

return module
