-- Canonical agent states
--
-- Agents report state by writing the `agent_state` user variable (see the
-- wezterm-agent-state helper in ~/.local/bin). Values are normalised here so
-- every agent renders the same way regardless of the vocabulary it uses.

local module = {}

-- Catppuccin Mocha. Deliberately avoids the per-agent accent colours in
-- agents/*.lua so state and identity never read as the same signal.
module.states = {
    working = { label = "working",   color = "#f9e2af" }, -- yellow
    idle    = { label = "idle",      color = "#a6e3a1" }, -- green
    waiting = { label = "needs you", color = "#f38ba8" }, -- red
}

-- Vocabulary each agent might emit, mapped onto the canonical states above.
-- Extend this rather than teaching tabs.lua about new words.
local ALIASES = {
    working = "working",
    busy = "working",
    running = "working",
    thinking = "working",

    idle = "idle",
    done = "idle",
    complete = "idle",
    finished = "idle",
    stop = "idle",

    waiting = "waiting",
    blocked = "waiting",
    input = "waiting",
    approval = "waiting",
    notification = "waiting",
}

--- Normalise a raw user-var value to a canonical state key.
-- @param raw string|nil
-- @return string|nil canonical state key, or nil if unrecognised
function module.normalize(raw)
    if not raw or raw == "" then
        return nil
    end
    return ALIASES[raw:lower()]
end

--- Resolve the state for a tab.
-- Precedence:
--   1. the `agent_state` user var (explicit, set by an agent hook)
--   2. has_unseen_output, which WezTerm tracks with no agent cooperation
-- @param tab TabInformation
-- @return string|nil canonical state key
-- @return boolean true when the state was inferred rather than reported
function module.resolve(tab)
    local pane = tab.active_pane
    if pane and pane.user_vars then
        local reported = module.normalize(pane.user_vars.agent_state)
        if reported then
            return reported, false
        end
    end

    -- Fallback: any pane in the tab produced output since it was last focused.
    -- Weaker than a reported state, but works for agents that cannot run hooks.
    if not tab.is_active then
        for _, p in ipairs(tab.panes or {}) do
            if p.has_unseen_output then
                return "waiting", true
            end
        end
    end

    return nil, false
end

return module
