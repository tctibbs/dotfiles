-- Keybindings configuration
-- Platform-aware modifiers (CMD on Mac, CTRL on Windows/Linux)

local module = {}

function module.apply(config, wezterm)
    local act = wezterm.action

    -- Platform detection for modifier keys
    local is_mac = wezterm.target_triple:find("darwin") or wezterm.target_triple:find("apple")
    local is_windows = wezterm.target_triple:find("windows")

    -- Platform-aware modifiers
    local mod = is_mac and "CMD" or "CTRL"
    local mod_shift = is_mac and "CMD|SHIFT" or "CTRL|SHIFT"

    config.keys = {
        -- Tab management (platform-aware)
        { key = "t", mods = mod, action = act.SpawnTab("CurrentPaneDomain") },
        { key = "w", mods = mod, action = act.CloseCurrentTab({ confirm = false }) },

        -- Rename tab
        {
            key = "r",
            mods = mod_shift,
            action = act.PromptInputLine({
                description = "Enter new tab name:",
                action = wezterm.action_callback(function(window, pane, line)
                    if line then
                        window:active_tab():set_title(line)
                    end
                end),
            }),
        },

        -- Pane splitting (universal CTRL+SHIFT)
        { key = "|", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
        { key = "_", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

        -- Close pane
        { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },

        -- Navigate panes
        { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
        { key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
        { key = "UpArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
        { key = "DownArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },

        -- Reload configuration (F5 to avoid conflict with rename on Windows/Linux)
        { key = "F5", mods = "CTRL|SHIFT", action = act.ReloadConfiguration },

        -- Clipboard (universal)
        { key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },

        -- Smart copy: copy if selection, else send SIGINT
        {
            key = "c",
            mods = "CTRL",
            action = wezterm.action_callback(function(window, pane)
                local selection = window:get_selection_text_for_pane(pane)
                if selection ~= "" then
                    window:perform_action(act.CopyTo("Clipboard"), pane)
                else
                    window:perform_action(act.SendKey({ key = "c", mods = "CTRL" }), pane)
                end
            end),
        },

        -- Shell picker (platform-aware options)
        {
            key = "p",
            mods = "CTRL|SHIFT",
            action = act.InputSelector({
                title = "Select Shell",
                choices = (function()
                    if is_windows then
                        return {
                            { label = "Ubuntu (WSL)", id = "wsl" },
                            { label = "PowerShell", id = "pwsh" },
                            { label = "Command Prompt", id = "cmd" },
                        }
                    else
                        return {
                            { label = "Zsh", id = "zsh" },
                            { label = "Bash", id = "bash" },
                        }
                    end
                end)(),
                action = wezterm.action_callback(function(window, pane, id, label)
                    if id == "pwsh" then
                        window:perform_action(
                            act.SpawnCommandInNewTab({
                                domain = { DomainName = "local" },
                                args = { "powershell.exe", "-NoLogo" },
                            }),
                            pane
                        )
                    elseif id == "wsl" then
                        window:perform_action(
                            act.SpawnCommandInNewTab({
                                domain = { DomainName = "WSL:Ubuntu" },
                            }),
                            pane
                        )
                    elseif id == "cmd" then
                        window:perform_action(
                            act.SpawnCommandInNewTab({
                                domain = { DomainName = "local" },
                                args = { "cmd.exe" },
                            }),
                            pane
                        )
                    elseif id == "zsh" then
                        window:perform_action(act.SpawnCommandInNewTab({ args = { "zsh" } }), pane)
                    elseif id == "bash" then
                        window:perform_action(act.SpawnCommandInNewTab({ args = { "bash" } }), pane)
                    end
                end),
            }),
        },
    }
end

return module
