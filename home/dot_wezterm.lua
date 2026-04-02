-- WezTerm Configuration
-- Entry point that loads modular configuration files
-- Cross-platform: macOS, Windows, Linux

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Load and apply modular configuration
require("theme").apply(config, wezterm)
require("platform").apply(config, wezterm)
require("keys").apply(config, wezterm)
require("tabs").apply(config, wezterm)

return config
