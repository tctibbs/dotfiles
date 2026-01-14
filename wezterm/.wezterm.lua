local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Load Modular Components
local theme = require("wezterm.theme")
local shells = require("wezterm.shells")
local keybinds = require("wezterm.keybinds")

-- Apply Components to Config
theme.apply_to_config(config)
shells.apply_to_config(config)
keybinds.apply_to_config(config)

return config