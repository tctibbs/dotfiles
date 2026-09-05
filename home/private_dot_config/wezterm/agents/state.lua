-- Canonical agent states
--
-- Agents report state by writing the `agent_state` user variable (see the
-- wezterm-agent-state helper in ~/.local/bin). Values are normalised here so
-- every agent renders the same way regardless of the vocabulary it uses.

local p = require("palette")

local module = {}

-- Deliberately avoids the per-agent accent colours in agents/*.lua so state
-- and identity never read as the same signal.
module.states = {
    working = { label = "working", color = p.yellow },
    idle = { label = "idle", color = p.green },
    waiting = { label = "needs you", color = p.red },
}

-- Vocabulary each agent might emit, mapped onto the canonical states above.
-- Extend this rather than teaching tabs/init.lua about new words.
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
--   2. has_unseen_output, but only for a tab known to be running an agent
--
-- The fallback is deliberately gated on `is_agent`. Without that gate every
-- background shell that prints a line turns "needs you", which is both wrong
-- and quickly trains you to ignore the colour.
--
-- Nothing is reported for a pane that is not a known agent, in either branch.
--
-- @param tab TabInformation
-- @param is_agent boolean whether the tab was identified as a trusted agent
-- @return string|nil canonical state key
-- @return boolean true when the state was inferred rather than reported
function module.resolve(tab, is_agent)
    -- Everything below is attacker-influenced: any program in a pane can write
    -- these. Nothing is honoured for a pane we have not identified as an agent,
    -- so a stray escape sequence cannot flip a tab to "needs you".
    if not is_agent then
        return nil, false
    end

    local pane = tab.active_pane
    if pane and pane.user_vars then
        local reported = module.normalize(pane.user_vars.agent_state)
        if reported then
            return reported, false
        end
    end

    -- An agent that cannot run hooks still produces output when it wants
    -- something, so unseen output in an unfocused tab is a usable signal.
    --
    -- Scoped to the active pane, matching where identity came from. Scanning
    -- every pane would flag a tab because of a split the agent is not in, and
    -- would not agree with the status rollup, which can only see one pane.
    if not tab.is_active and pane and pane.has_unseen_output then
        return "waiting", true
    end

    return nil, false
end

return module
