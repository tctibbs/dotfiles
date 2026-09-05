-- Right status: a one-line rollup of every agent in the window.
--
-- The tab bar answers "what is this tab doing". This answers "is anything
-- waiting on me" without reading the tabs at all, which is the question you
-- actually have when several agents are running.

local wezterm = require("wezterm")
local p = require("palette")
local agents = require("agents")
local agent_state = require("agents.state")

local nf = wezterm.nerdfonts
local module = {}

-- Rendered left to right; anything with a zero count is omitted.
local ORDER = {
    { state = "waiting", glyph = nf.md_alert_circle, color = p.red },
    { state = "working", glyph = nf.md_progress_clock, color = p.yellow },
    { state = "idle", glyph = nf.md_check_circle, color = p.green },
}

--- Count agent states across every pane in the window.
-- Reads the same user vars the tab bar uses, so the two can never disagree.
local function tally(window)
    local counts = { working = 0, idle = 0, waiting = 0 }
    local total = 0

    local ok, mux_window = pcall(function()
        return window:mux_window()
    end)
    if not ok or not mux_window then
        return counts, total
    end

    for _, tab in ipairs(mux_window:tabs()) do
        for _, pane in ipairs(tab:panes()) do
            local vars = pane:get_user_vars() or {}
            if agents.get(vars.agent_id) then
                total = total + 1
                local state = agent_state.normalize(vars.agent_state)
                if state and counts[state] then
                    counts[state] = counts[state] + 1
                end
            end
        end
    end

    return counts, total
end

function module.apply(config, wezterm_mod)
    local wt = wezterm_mod or wezterm

    -- Default cadence is 1s; the tally is a handful of table reads, but there
    -- is no reason to run it faster than a human reacts.
    config.status_update_interval = 2000

    wt.on("update-status", function(window, _pane)
        local counts, total = tally(window)

        if total == 0 then
            window:set_right_status("")
            return
        end

        local cells = {}
        for _, entry in ipairs(ORDER) do
            local n = counts[entry.state]
            if n > 0 then
                cells[#cells + 1] = { Foreground = { Color = entry.color } }
                cells[#cells + 1] = { Text = " " .. entry.glyph .. " " .. tostring(n) }
            end
        end

        if #cells == 0 then
            window:set_right_status("")
            return
        end

        cells[#cells + 1] = { Foreground = { Color = p.surface2 } }
        cells[#cells + 1] = { Text = "  " }

        window:set_right_status(wt.format(cells))
    end)
end

return module
