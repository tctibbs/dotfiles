-- Platform-specific configuration
-- Handles macOS, Windows, and Linux settings

local module = {}

function module.apply(config, wezterm)
    -- Platform detection
    local is_windows = wezterm.target_triple:find("windows")
    local is_mac = wezterm.target_triple:find("darwin") or wezterm.target_triple:find("apple")
    local is_linux = wezterm.target_triple:find("linux")

    -- Universal settings (all platforms)
    config.front_end = "WebGpu"
    config.webgpu_power_preference = "HighPerformance"
    config.window_close_confirmation = "NeverPrompt"

    -- Platform-specific settings
    if is_mac then
        -- macOS settings
        config.macos_window_background_blur = 10
        config.native_macos_fullscreen_mode = true
        config.send_composed_key_when_left_alt_is_pressed = false
        config.send_composed_key_when_right_alt_is_pressed = false
        config.default_prog = { "/bin/zsh", "-l" }

    elseif is_windows then
        -- Windows settings (WSL integration)
        config.default_domain = "WSL:Ubuntu"
        config.wsl_domains = wezterm.default_wsl_domains()
        -- Fallback if WSL not available
        config.launch_menu = {
            { label = "PowerShell", args = { "powershell.exe", "-NoLogo" } },
            { label = "Command Prompt", args = { "cmd.exe" } },
        }

    elseif is_linux then
        -- Linux settings
        config.default_prog = { "zsh", "--login" }
    end

    -- Export platform info for use in other modules
    module.is_mac = is_mac
    module.is_windows = is_windows
    module.is_linux = is_linux
end

return module
