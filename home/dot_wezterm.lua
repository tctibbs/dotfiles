-- WezTerm Configuration
-- Entry point that loads modular configuration files
-- Cross-platform: macOS, Windows, Linux

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Load and apply modular configuration
require("theme").apply(config)
require("platform").apply(config)
require("keys").apply(config)
require("tabs").apply(config)
require("status").apply(config)

return config
