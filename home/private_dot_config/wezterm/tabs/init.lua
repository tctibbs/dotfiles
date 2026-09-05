-- Tab bar rendering
--
-- Composes each tab from three inputs and decides only how they look:
--   agents/         which coding agent is running  (identity)
--   agents.state    what that agent is doing       (state)
--   tabs.processes  fallback icon for plain shells
--
-- Requires the retro tab bar (use_fancy_tab_bar = false, set in theme.lua).
-- The fancy bar renders in a proportional system font with no Nerd Font
-- coverage, and composites its own close button over whatever this returns.
--
-- Repaint is event driven: an OSC 1337 SetUserVar write fires user-var-changed,
-- which posts update_title and rebuilds the tab bar, so agent state appears as
-- soon as it is reported rather than on a poll interval.
--
-- Width is measured with wezterm.column_width and cut with
-- wezterm.truncate_right. Lua's # operator counts BYTES: "…" is 3 bytes but
-- one cell, and every Nerd Font glyph is 3-4 bytes wide, so byte arithmetic
-- both over-reserves space and can slice a codepoint in half.

local wezterm = require("wezterm")
local p = require("palette")
local agents = require("agents")
local agent_state = require("agents.state")
local processes = require("tabs.processes")
local text = require("text")

local nf = wezterm.nerdfonts
local module = {}

local SEP_LEFT = nf.ple_left_half_circle_thick
local SEP_RIGHT = nf.ple_right_half_circle_thick

-- Reported state gets a solid dot; state merely inferred from unseen output
-- gets a smaller one, so a guess never looks like a fact.
local DOT_REPORTED = nf.md_circle_medium
local DOT_INFERRED = nf.md_circle_small

local ELLIPSIS = "…"

-- Below this many cells a title is noise rather than information, so the
-- optional decorations are dropped to buy it room.
local MIN_TITLE_CELLS = 5

--- Display width in terminal cells.
-- wezterm.column_width errors on nil and counts control characters as zero
-- width, so a title carrying a tab or newline would measure short and then
-- overflow its budget. Both are handled before measuring.
local function cells(s)
    return wezterm.column_width(s or "")
end

--- Bare executable name of the tab's foreground process.
local function process_name(tab)
    local pane = tab.active_pane
    return text.basename(pane and pane.foreground_process_name)
end

-- A pane whose program never sets a title inherits the terminal's own window
-- title, which is worse than useless in a tab. Treat these as absent.
local UNHELPFUL_TITLES = {
    ["wezterm"] = true,
    ["wezterm-gui"] = true,
}

--- Best available title, preferring one that was set deliberately.
-- Precedence: an explicitly set tab title, then the pane title, then the
-- foreground process name.
-- @param proc string|nil already-resolved process name, to avoid re-reading
--   the lazily computed PaneInformation field
local function base_title(tab, proc)
    local explicit = text.sanitize(tab.tab_title)
    if explicit ~= "" then
        return explicit
    end

    -- Strip WezTerm's copy-mode prefix BEFORE sanitizing, so sanitize stays
    -- the last word. Editing a title after the gate can re-admit one that
    -- measures zero cells, which is what the gate exists to prevent.
    local raw = tab.active_pane and tab.active_pane.title
    if type(raw) == "string" then
        raw = (raw:gsub("^Copy mode: ", ""))
    end

    local pane_title = text.sanitize(raw)
    if pane_title ~= "" and not UNHELPFUL_TITLES[text.ascii_lower(pane_title)] then
        return pane_title
    end

    return text.sanitize(proc) ~= "" and text.sanitize(proc) or "shell"
end

--- Cut to a cell budget, marking the cut with an ellipsis.
local function fit(title, budget)
    if budget <= 0 then
        return ""
    end
    if cells(title) <= budget then
        return title
    end
    if budget == 1 then
        return ELLIPSIS
    end
    return wezterm.truncate_right(title, budget - 1) .. ELLIPSIS
end

--- Decide which decorations survive at this width.
--
-- Separators are structural and always drawn. The icon and the state dot are
-- dropped, in that order, and only when keeping them would squeeze the title
-- below what it actually needs.
--
-- The retro tab bar sizes a tab to its content when there is room, so a narrow
-- max_width usually means a SHORT TITLE, not a cramped bar. Comparing against
-- a fixed minimum would strip the icon from every short-titled tab, which is
-- exactly backwards.
--
-- @param max_width number cells available for this tab
-- @param title string the title as it would ideally be shown
-- @param wants_state boolean whether a state dot is available to draw
local function layout(max_width, title, wants_state)
    local plan = { icon = true, state = wants_state }
    local needed = math.min(cells(title), MIN_TITLE_CELLS)

    -- Always drawn: SEP_LEFT(1) + the space before the title(1)
    -- + the trailing space(1) + SEP_RIGHT(1). The icon and the state dot each
    -- add their own leading space, so they cost 2 cells apiece.
    local function overhead()
        local n = 4
        if plan.icon then
            n = n + 2
        end
        if plan.state then
            n = n + 2
        end
        return n
    end

    if max_width - overhead() < needed and plan.icon then
        plan.icon = false
    end
    if max_width - overhead() < needed and plan.state then
        plan.state = false
    end

    plan.overhead = overhead()
    plan.title_budget = max_width - plan.overhead
    return plan
end

--- Ordered, dense list of icon lookup keys. ipairs stops at the first nil, so
--- the list must not contain holes.
local function candidates(...)
    local out = {}
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if type(v) == "string" and v ~= "" then
            out[#out + 1] = v
        end
    end
    return out
end

--- Resolve every colour and glyph for one tab.
local function resolve(tab, hover)
    local agent, method = agents.detect(tab)
    local proc = process_name(tab)

    -- Identity from a title match is a guess and only earns an icon. Letting it
    -- drive state would let any program flip a tab red by printing a title.
    local trusted = agent ~= nil and agents.is_trusted(method)
    local state, inferred = agent_state.resolve(tab, trusted)
    local state_def = state and agent_state.states[state]

    local title = base_title(tab, proc)
    local look = {
        icon = agent and agent.icon or processes.icon_for(candidates(proc, title)),
        title = title,
        bg = p.surface0,
        fg = p.subtext1,
        accent = agent and agent.color or p.subtext0,
        dot = state_def and (inferred and DOT_INFERRED or DOT_REPORTED) or nil,
        dot_color = state_def and state_def.color or nil,
        bold = false,
    }

    if tab.is_active then
        look.bg = p.blue
        look.fg = p.base
        look.accent = p.base
        look.dot_color = look.dot and p.base or nil
        look.bold = true
    elseif hover then
        look.bg = p.surface1
        look.fg = p.text
    end

    -- Needing input outranks every other styling decision: the whole tab
    -- flips so it reads from the far side of the screen.
    if state == "waiting" then
        look.bg = state_def.color
        look.fg = p.base
        look.accent = p.base
        look.dot_color = p.base
        look.bold = true
    end

    return look
end

function module.apply(config)
    wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, hover, max_width)
        local look = resolve(tab, hover)
        local plan = layout(max_width, look.title, look.dot ~= nil)
        local title = fit(look.title, plan.title_budget)

        -- Too narrow for chrome plus at least one cell of title. WezTerm would
        -- resolve an overflow by hard-cutting mid-glyph, and chrome with no
        -- title at all says nothing. Degrade to plain text sized to the budget.
        if plan.title_budget < 1 or plan.overhead + cells(title) > max_width then
            return {
                { Background = { Color = look.bg } },
                { Foreground = { Color = look.fg } },
                { Text = wezterm.truncate_right(look.title, max_width) },
            }
        end

        local out = {
            { Background = { Color = p.base } },
            { Foreground = { Color = look.bg } },
            { Text = SEP_LEFT },
            { Background = { Color = look.bg } },
        }

        if plan.icon then
            out[#out + 1] = { Foreground = { Color = look.accent } }
            out[#out + 1] = { Text = " " .. look.icon }
        end

        out[#out + 1] = { Foreground = { Color = look.fg } }
        out[#out + 1] = { Attribute = { Intensity = look.bold and "Bold" or "Normal" } }
        out[#out + 1] = { Text = " " .. title }

        if plan.state then
            out[#out + 1] = { Foreground = { Color = look.dot_color } }
            out[#out + 1] = { Text = " " .. look.dot }
        end

        out[#out + 1] = { Attribute = { Intensity = "Normal" } }
        out[#out + 1] = { Text = " " }
        out[#out + 1] = { Background = { Color = p.base } }
        out[#out + 1] = { Foreground = { Color = look.bg } }
        out[#out + 1] = { Text = SEP_RIGHT }

        return out
    end)

    -- Retro tab bar chrome, kept in the same visual language as the tabs.
    config.tab_bar_style = {
        new_tab = wezterm.format({
            { Background = { Color = p.base } },
            { Foreground = { Color = p.overlay0 } },
            { Text = "  " .. (nf.md_plus or "+") .. " " },
        }),
        new_tab_hover = wezterm.format({
            { Background = { Color = p.base } },
            { Foreground = { Color = p.text } },
            { Text = "  " .. (nf.md_plus or "+") .. " " },
        }),
    }
end

return module
