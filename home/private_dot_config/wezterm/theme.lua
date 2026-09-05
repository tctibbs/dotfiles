-- Theme configuration
-- Catppuccin Mocha colors with FiraCode Nerd Font.
-- Colour values come from palette.lua so they stay in step with the tab bar.

local p = require("palette")

local module = {}

function module.apply(config, wezterm)
    -- Font configuration
    -- Try multiple FiraCode Nerd Font name variants
    config.font = wezterm.font_with_fallback({
        { family = "FiraCode Nerd Font Mono", weight = "Regular" },
        { family = "FiraCode Nerd Font", weight = "Regular" },
        { family = "FiraCode NF", weight = "Regular" },
        { family = "FiraCodeNF", weight = "Regular" },
        "Consolas",
        "Monaco",
    })
    config.font_size = 13.0
    config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

    -- Catppuccin Mocha color scheme
    config.colors = {
        foreground = p.text,
        background = p.base,

        cursor_bg = p.rosewater,
        cursor_fg = p.base,
        cursor_border = p.rosewater,

        selection_fg = p.base,
        selection_bg = p.blue,

        scrollbar_thumb = p.surface2,
        split = p.overlay0,

        -- ANSI colors (normal)
        ansi = {
            p.surface1, -- black
            p.red,
            p.green,
            p.yellow,
            p.blue,
            p.mauve, -- magenta
            p.teal, -- cyan
            p.subtext1, -- white
        },

        -- ANSI colors (bright)
        brights = {
            p.surface2, -- bright black
            p.red,
            p.green,
            p.yellow,
            p.blue,
            p.mauve,
            p.teal,
            p.subtext0, -- bright white
        },

        -- Tab bar colors. The retro tab bar draws tab titles through
        -- format-tab-title in tabs/init.lua; these cover the surrounding chrome.
        tab_bar = {
            background = p.base,
            active_tab = { bg_color = p.blue, fg_color = p.base, intensity = "Bold" },
            inactive_tab = { bg_color = p.surface0, fg_color = p.subtext1 },
            inactive_tab_hover = { bg_color = p.surface1, fg_color = p.text },
            new_tab = { bg_color = p.surface0, fg_color = p.subtext1 },
            new_tab_hover = { bg_color = p.surface1, fg_color = p.text },
        },
    }

    -- Window appearance (Windows-style buttons on right for clean look)
    config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
    config.integrated_title_button_style = "Windows"
    config.integrated_title_button_alignment = "Right"
    config.window_padding = {
        left = 8,
        right = 8,
        top = 8,
        bottom = 8,
    }

    -- Background image with dark overlay (optional)
    -- Download a wallpaper to ~/.config/wezterm/background.jpg
    local bg_path = wezterm.home_dir .. "/.config/wezterm/background.jpg"
    local f = io.open(bg_path, "r")
    if f then
        f:close()
        config.background = {
            {
                source = { File = bg_path },
                hsb = { brightness = 0.15 },
                width = "Cover",
                height = "Cover",
            },
            {
                source = { Color = p.base },
                width = "100%",
                height = "100%",
                opacity = 0.7,
            },
        }
    end

    -- Tab bar settings
    config.hide_tab_bar_if_only_one_tab = true
    -- Retro tab bar renders as terminal cells, which is what lets tabs/init.lua
    -- control per-tab background and draw powerline separators. The fancy bar
    -- composites its own chrome over format-tab-title output.
    config.use_fancy_tab_bar = false
    config.tab_bar_at_bottom = false
    config.tab_max_width = 40

    -- Scrollback
    config.scrollback_lines = 10000

    -- Bell configuration
    config.audible_bell = "Disabled"
    config.visual_bell = {
        fade_in_duration_ms = 75,
        fade_out_duration_ms = 75,
        target = "CursorColor",
    }

    -- Enable Kitty graphics protocol (for image.nvim, etc.)
    config.enable_kitty_graphics = true

    -- Cursor styling
    config.default_cursor_style = "BlinkingBar"
    config.cursor_blink_rate = 500
    config.cursor_blink_ease_in = "EaseIn"
    config.cursor_blink_ease_out = "EaseOut"
end

return module
