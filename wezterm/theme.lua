-- Theme configuration
-- Catppuccin Mocha colors with FiraCode Nerd Font

local module = {}

function module.apply(config, wezterm)
    -- Font configuration
    config.font = wezterm.font_with_fallback({
        { family = "FiraCode Nerd Font", weight = "Regular" },
        "Consolas",
        "Monaco",
    })
    config.font_size = 13.0
    config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

    -- Catppuccin Mocha color scheme
    config.colors = {
        foreground = "#cdd6f4",
        background = "#1e1e2e",

        cursor_bg = "#f5e0dc",
        cursor_fg = "#1e1e2e",
        cursor_border = "#f5e0dc",

        selection_fg = "#1e1e2e",
        selection_bg = "#89b4fa",

        scrollbar_thumb = "#585b70",
        split = "#6c7086",

        -- ANSI colors (normal)
        ansi = {
            "#45475a", -- black (surface0)
            "#f38ba8", -- red
            "#a6e3a1", -- green
            "#f9e2af", -- yellow
            "#89b4fa", -- blue
            "#cba6f7", -- magenta (mauve)
            "#94e2d5", -- cyan (teal)
            "#bac2de", -- white (subtext1)
        },

        -- ANSI colors (bright)
        brights = {
            "#585b70", -- bright black (surface2)
            "#f38ba8", -- bright red
            "#a6e3a1", -- bright green
            "#f9e2af", -- bright yellow
            "#89b4fa", -- bright blue
            "#cba6f7", -- bright magenta
            "#94e2d5", -- bright cyan
            "#a6adc8", -- bright white (subtext0)
        },

        -- Tab bar colors
        tab_bar = {
            background = "#1e1e2e",
            active_tab = {
                bg_color = "#89b4fa",
                fg_color = "#1e1e2e",
                intensity = "Bold",
            },
            inactive_tab = {
                bg_color = "#313244",
                fg_color = "#cdd6f4",
            },
            inactive_tab_hover = {
                bg_color = "#45475a",
                fg_color = "#cdd6f4",
            },
            new_tab = {
                bg_color = "#313244",
                fg_color = "#cdd6f4",
            },
            new_tab_hover = {
                bg_color = "#45475a",
                fg_color = "#cdd6f4",
            },
        },
    }

    -- Window appearance (INTEGRATED_BUTTONS gives title bar with native double-click to maximize)
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
                source = { Color = "#1e1e2e" },
                width = "100%",
                height = "100%",
                opacity = 0.7,
            },
        }
    end

    -- Tab bar settings
    config.hide_tab_bar_if_only_one_tab = true
    config.use_fancy_tab_bar = true
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
