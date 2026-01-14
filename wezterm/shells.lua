local wezterm = require("wezterm")
local module = {}

function module.apply_to_config(config)
    -- Detect Platform
    local is_windows = wezterm.target_triple:find("windows")
    local is_mac = wezterm.target_triple:find("apple")
    local is_linux = wezterm.target_triple:find("linux")

    if is_windows then
        -- Windows Logic
        config.default_domain = 'WSL:Ubuntu'
        config.wsl_domains = wezterm.default_wsl_domains()
    elseif is_mac or is_linux then
        -- Unix/Linux Logic
        config.default_prog = { 'zsh', '--login' }
    end

    -- Universal Settings
    config.front_end = "WebGpu"
    config.window_close_confirmation = 'NeverPrompt'
end

return module
