-- WezTerm Configuration
-- =====================
-- Catppuccin Mocha theme with FiraCode Nerd Font
-- Cross-platform compatible (macOS/Linux)

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ===================================
-- Font Configuration
-- ===================================

config.font = wezterm.font('FiraCode Nerd Font', { weight = 'Regular' })
config.font_size = 13.0

-- Enable ligatures
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- ===================================
-- Catppuccin Mocha Color Scheme
-- ===================================

config.colors = {
    foreground = '#cdd6f4',
    background = '#1e1e2e',

    cursor_bg = '#f5e0dc',
    cursor_fg = '#1e1e2e',
    cursor_border = '#f5e0dc',

    selection_fg = '#1e1e2e',
    selection_bg = '#89b4fa',

    scrollbar_thumb = '#585b70',
    split = '#6c7086',

    -- ANSI colors (normal)
    ansi = {
        '#45475a', -- black (surface0)
        '#f38ba8', -- red
        '#a6e3a1', -- green
        '#f9e2af', -- yellow
        '#89b4fa', -- blue
        '#cba6f7', -- magenta (mauve)
        '#94e2d5', -- cyan (teal)
        '#bac2de', -- white (subtext1)
    },

    -- ANSI colors (bright)
    brights = {
        '#585b70', -- bright black (surface2)
        '#f38ba8', -- bright red
        '#a6e3a1', -- bright green
        '#f9e2af', -- bright yellow
        '#89b4fa', -- bright blue
        '#cba6f7', -- bright magenta
        '#94e2d5', -- bright cyan
        '#a6adc8', -- bright white (subtext0)
    },

    -- Tab bar colors
    tab_bar = {
        background = '#1e1e2e',
        active_tab = {
            bg_color = '#89b4fa',
            fg_color = '#1e1e2e',
            intensity = 'Bold',
        },
        inactive_tab = {
            bg_color = '#313244',
            fg_color = '#cdd6f4',
        },
        inactive_tab_hover = {
            bg_color = '#45475a',
            fg_color = '#cdd6f4',
        },
        new_tab = {
            bg_color = '#313244',
            fg_color = '#cdd6f4',
        },
        new_tab_hover = {
            bg_color = '#45475a',
            fg_color = '#cdd6f4',
        },
    },
}

-- ===================================
-- Image Protocol Support
-- ===================================

-- Enable Kitty graphics protocol (for mdfried, image.nvim, etc.)
config.enable_kitty_graphics = true

-- Allow passthrough for tmux image protocols
config.allow_passthrough = 'UpdateOnly'

-- ===================================
-- Window Appearance
-- ===================================

config.window_background_opacity = 1.0
config.window_decorations = 'RESIZE'
config.window_padding = {
    left = 8,
    right = 8,
    top = 8,
    bottom = 8,
}

-- Tab bar settings
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false

-- ===================================
-- GPU Acceleration
-- ===================================

config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'

-- ===================================
-- Scrollback
-- ===================================

config.scrollback_lines = 10000

-- ===================================
-- macOS-Specific Settings
-- ===================================

if wezterm.target_triple:find('darwin') then
    -- Subtle window blur on macOS
    config.macos_window_background_blur = 10

    -- Use native macOS fullscreen
    config.native_macos_fullscreen_mode = true

    -- Option key as Alt for terminal sequences
    config.send_composed_key_when_left_alt_is_pressed = false
    config.send_composed_key_when_right_alt_is_pressed = false
end

-- ===================================
-- Keybindings
-- ===================================

config.keys = {
    -- Quick split panes (similar to tmux bindings)
    {
        key = '|',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
        key = '_',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },

    -- Close pane
    {
        key = 'w',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.CloseCurrentPane { confirm = true },
    },

    -- Navigate panes
    {
        key = 'LeftArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivatePaneDirection 'Left',
    },
    {
        key = 'RightArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivatePaneDirection 'Right',
    },
    {
        key = 'UpArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivatePaneDirection 'Up',
    },
    {
        key = 'DownArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivatePaneDirection 'Down',
    },
}

-- ===================================
-- Misc Settings
-- ===================================

-- Reduce visual bell
config.audible_bell = 'Disabled'
config.visual_bell = {
    fade_in_duration_ms = 75,
    fade_out_duration_ms = 75,
    target = 'CursorColor',
}

-- Don't prompt on close
config.window_close_confirmation = 'NeverPrompt'

-- Default shell
config.default_prog = { '/bin/zsh', '-l' }

return config
