-- Tab bar rendering
--
-- Renders powerline-separated tabs showing which coding agent is running and
-- what it is doing. Identity and state come from agents/ — this file only
-- decides how they look.
--
-- Requires the retro tab bar (use_fancy_tab_bar = false, set in theme.lua).
-- The fancy tab bar draws its own chrome and composites a close button over
-- whatever this returns, so per-tab backgrounds cannot be controlled there.

local agents = require("agents")
local agent_state = require("agents.state")

local module = {}

-- Catppuccin Mocha
local palette = {
    edge = "#1e1e2e", -- base, the tab bar background
    inactive_bg = "#313244", -- surface0
    inactive_fg = "#bac2de", -- subtext1
    hover_bg = "#45475a", -- surface1
    active_bg = "#89b4fa", -- blue
    active_fg = "#cdd6f4", -- text
    dim = "#6c7086", -- overlay0
}

local SEP_LEFT = "" -- solid left half-circle
local SEP_RIGHT = "" -- solid right arrow

-- Fallback icons for non-agent tabs.
local process_icons = {
    ["zsh"] = "󰆍",
    ["bash"] = "󰆍",
    ["fish"] = "󰆍",
    ["sh"] = "󰆍",
    ["nvim"] = "󰕷",
    ["vim"] = "󰕷",
    ["vi"] = "󰕷",
    ["lazygit"] = "󰊢",
    ["git"] = "󰊢",
    ["node"] = "󰎙",
    ["npm"] = "󰎙",
    ["python"] = "󰌠",
    ["python3"] = "󰌠",
    ["pip"] = "󰌠",
    ["docker"] = "󰡨",
    ["lazydocker"] = "󰡨",
    ["ssh"] = "󰣀",
    ["btop"] = "󰍛",
    ["htop"] = "󰍛",
    ["top"] = "󰍛",
    ["cargo"] = "",
    ["rustc"] = "",
    ["go"] = "",
    ["make"] = "󰣪",
    ["cmake"] = "󰣪",
    ["lua"] = "󰢱",
    ["ruby"] = "",
    ["brew"] = "󱄖",
    ["man"] = "󰋖",
}

local DEFAULT_ICON = "󰅬"
local STATE_GLYPH = "●"

--- Bare executable name of the tab's foreground process.
local function process_name(tab)
    local name = tab.active_pane and tab.active_pane.foreground_process_name
    if not name or name == "" then
        return "shell"
    end
    return name:gsub("(.*[/\\])(.*)", "%2")
end

--- Best available title for a tab, preferring one the user set explicitly.
local function base_title(tab)
    if tab.tab_title and #tab.tab_title > 0 then
        return tab.tab_title
    end

    local pane_title = tab.active_pane and tab.active_pane.title
    if pane_title and pane_title ~= "" then
        return (pane_title:gsub("^Copy mode: ", ""))
    end

    return process_name(tab)
end

local function truncate(str, max_len)
    if max_len < 1 then
        return ""
    end
    if #str > max_len then
        return str:sub(1, max_len - 1) .. "…"
    end
    return str
end

--- Resolve every colour and glyph for a tab in one pass.
local function resolve(tab, hover)
    local agent = agents.detect(tab)
    local state = agent_state.resolve(tab)
    local state_def = state and agent_state.states[state]

    local look = {
        icon = agent and agent.icon or (process_icons[process_name(tab)] or DEFAULT_ICON),
        title = base_title(tab),
        bg = palette.inactive_bg,
        fg = palette.inactive_fg,
        accent = agent and agent.color or nil,
        state_color = state_def and state_def.color or nil,
        bold = false,
    }

    if tab.is_active then
        look.bg = palette.active_bg
        look.fg = palette.edge
        look.accent = palette.edge
        look.state_color = state_def and palette.edge or nil
        look.bold = true
    elseif hover then
        look.bg = palette.hover_bg
        look.fg = palette.active_fg
    end

    -- A tab that needs you outranks every other styling decision: the whole
    -- tab flips so it reads from the far side of the screen.
    if state == "waiting" then
        look.bg = state_def.color
        look.fg = palette.edge
        look.accent = palette.edge
        look.state_color = palette.edge
        look.bold = true
    end

    return look
end

function module.apply(config, wezterm)
    wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, hover, max_width)
        local look = resolve(tab, hover)

        -- Budget: two separators, icon plus its padding, and the state dot.
        local reserved = look.state_color and 6 or 4
        local title = truncate(look.title, math.max(max_width - reserved, 1))

        local cells = {
            { Background = { Color = palette.edge } },
            { Foreground = { Color = look.bg } },
            { Text = SEP_LEFT },

            { Background = { Color = look.bg } },
            { Foreground = { Color = look.accent or look.fg } },
            { Text = " " .. look.icon .. " " },

            { Foreground = { Color = look.fg } },
            { Attribute = { Intensity = look.bold and "Bold" or "Normal" } },
            { Text = title },
        }

        if look.state_color then
            table.insert(cells, { Foreground = { Color = look.state_color } })
            table.insert(cells, { Attribute = { Intensity = "Bold" } })
            table.insert(cells, { Text = " " .. STATE_GLYPH })
        end

        table.insert(cells, { Text = " " })
        table.insert(cells, { Background = { Color = palette.edge } })
        table.insert(cells, { Foreground = { Color = look.bg } })
        table.insert(cells, { Text = SEP_RIGHT })

        return cells
    end)

    -- Retro tab bar chrome: keep the new-tab button in the same visual language.
    config.tab_bar_style = {
        new_tab = wezterm.format({
            { Background = { Color = palette.edge } },
            { Foreground = { Color = palette.dim } },
            { Text = "  " },
        }),
        new_tab_hover = wezterm.format({
            { Background = { Color = palette.edge } },
            { Foreground = { Color = palette.active_fg } },
            { Text = "  " },
        }),
    }
end

return module
