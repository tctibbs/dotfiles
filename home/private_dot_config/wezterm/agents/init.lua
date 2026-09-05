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

--- Identify which agent, if any, is running in a tab.
-- @param tab TabInformation
-- @return table|nil agent definition
-- @return string detection method: "user_var" | "process" | "title"
function module.detect(tab)
    local pane = tab.active_pane
    if not pane then
        return nil
    end

    -- 1. Explicitly reported by the agent itself.
    if pane.user_vars then
        local agent = by_id[pane.user_vars.agent_id or ""]
        if agent then
            return agent, "user_var"
        end
    end

    -- 2. Foreground process name.
    local process = pane.foreground_process_name
    if process and process ~= "" then
        local exe = process:gsub("(.*[/\\])(.*)", "%2"):lower()
        for _, agent in ipairs(ordered) do
            for _, candidate in ipairs(agent.processes or {}) do
                if exe == candidate then
                    return agent, "process"
                end
            end
        end
    end

    -- 3. Title text. Fragile by nature — kept last.
    local title = (tab.tab_title ~= "" and tab.tab_title) or pane.title
    if title and title ~= "" then
        local haystack = title:lower()
        for _, agent in ipairs(ordered) do
            for _, pattern in ipairs(agent.title_patterns or {}) do
                if haystack:find(pattern) then
                    return agent, "title"
                end
            end
        end
    end

    return nil
end

return module
