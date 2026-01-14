local wezterm = require("wezterm")
local module = {}

function module.apply_to_config(config)
    local is_windows = wezterm.target_triple:find("windows")

    config.keys = {
        { key = 't', mods = 'CTRL', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
        { key = 'w', mods = 'CTRL', action = wezterm.action.CloseCurrentTab { confirm = false } },
        { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
        { key = 'r', mods = 'CTRL|SHIFT', action = wezterm.action.ReloadConfiguration },

        -- SMART CROSS-PLATFORM PICKER
        {
            key = 'p',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.InputSelector {
                title = "🚀 Select Shell",
                choices = (function()
                    if is_windows then
                        return {
                            { label = "Ubuntu (WSL)", id = "wsl" },
                            { label = "PowerShell", id = "pwsh" },
                        }
                    else
                        return {
                            { label = "Zsh (Native)", id = "zsh" },
                            { label = "Bash", id = "bash" },
                        }
                    end
                end)(),
                action = wezterm.action_callback(function(window, pane, id, label)
                    if id == "pwsh" then
                        window:perform_action(wezterm.action.SpawnCommandInNewTab {
                            domain = { DomainName = 'local' },
                            args = { 'powershell.exe', '-NoLogo' },
                        }, pane)
                    elseif id == "wsl" then
                        window:perform_action(wezterm.action.SpawnCommandInNewTab {
                            domain = { DomainName = 'WSL:Ubuntu' },
                            cwd = "/home/tristan",
                        }, pane)
                    elseif id == "zsh" then
                        window:perform_action(wezterm.action.SpawnTab { args = { 'zsh' } }, pane)
                    elseif id == "bash" then
                        window:perform_action(wezterm.action.SpawnTab { args = { 'bash' } }, pane)
                    end
                end),
            },
        },

        -- Smart Copy
        {
            key = 'c',
            mods = 'CTRL',
            action = wezterm.action_callback(function(window, pane)
                local selection = window:get_selection_text_for_pane(pane)
                if selection ~= "" then
                    window:perform_action(wezterm.action.CopyTo 'Clipboard', pane)
                else
                    window:perform_action(wezterm.action.SendKey { key = 'c', mods = 'CTRL' }, pane)
                end
            end),
        },
    }
end

return module