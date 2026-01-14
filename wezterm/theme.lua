local wezterm = require("wezterm")
local module = {}

function module.apply_to_config(config)
    config.font = wezterm.font_with_fallback({
        'FiraCode Nerd Font',
        'Consolas',
    })
    config.font_size = 12.0
    config.colors = {
        foreground = '#cdd6f4',
        background = '#1e1e2e',
        cursor_bg = '#f5e0dc',
        cursor_fg = '#1e1e2e',
        ansi = { '#45475a', '#f38ba8', '#a6e3a1', '#f9e2af', '#89b4fa', '#cba6f7', '#94e2d5', '#bac2de' },
        brights = { '#585b70', '#f38ba8', '#a6e3a1', '#f9e2af', '#89b4fa', '#cba6f7', '#94e2d5', '#a6adc8' },
        tab_bar = {
            background = '#11111b',
            active_tab = { bg_color = '#89b4fa', fg_color = '#11111b' },
            inactive_tab = { bg_color = '#1e1e2e', fg_color = '#a6adc8' },
        }
    }
    config.window_decorations = "TITLE | RESIZE"
    config.window_padding = { left = 8, right = 8, top = 10, bottom = 8 }
    config.hide_tab_bar_if_only_one_tab = true
    config.use_fancy_tab_bar = false
end

return module