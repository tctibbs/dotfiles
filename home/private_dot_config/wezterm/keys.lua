-- Keybindings configuration
-- Platform-aware modifiers (CMD on Mac, CTRL on Windows/Linux)

local wezterm = require("wezterm")

local module = {}

-- Renaming is defined once and reached three ways: a keybinding, a middle-click
-- on the new-tab button, and the command palette.
--
-- Double-clicking a tab is deliberately absent, because it cannot be done.
-- WezTerm hit-tests tab-bar UI items before consulting mouse_bindings, and the
-- two sit in opposite branches of the same if/else, so a tab click never
-- reaches user config. MouseEventTrigger has no region field either, so the
-- binding is not expressible. new-tab-button-click is the only tab-bar mouse
-- event exposed to Lua.
local function rename_action()
    return wezterm.action.PromptInputLine({
        description = "Enter new tab name:",
        action = wezterm.action_callback(function(window, _pane, line)
            -- nil means cancelled. An empty string clears the override, so the
            -- tab goes back to tracking whatever is running in it.
            if line then
                window:active_tab():set_title(line)
            end
        end),
    })
end

function module.apply(config)
    local act = wezterm.action

    -- Platform detection for modifier keys
    local is_mac = wezterm.target_triple:find("darwin") or wezterm.target_triple:find("apple")
    local is_windows = wezterm.target_triple:find("windows")

    -- Platform-aware modifiers
    local mod = is_mac and "CMD" or "CTRL"
    local mod_shift = is_mac and "CMD|SHIFT" or "CTRL|SHIFT"

    config.keys = {
        -- Toggle fullscreen (Cmd+Enter on Mac, Ctrl+Enter on Windows/Linux)
        { key = "Enter", mods = mod, action = act.ToggleFullScreen },

        -- Tab management (platform-aware)
        { key = "t", mods = mod, action = act.SpawnTab("CurrentPaneDomain") },
        { key = "w", mods = mod, action = act.CloseCurrentTab({ confirm = false }) },

        -- Rename tab
        { key = "r", mods = mod_shift, action = rename_action() },

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


    -- Middle-click the new-tab button to rename the current tab.
    --
    -- This is the only mouse gesture in the tab bar that WezTerm hands to Lua.
    -- Left and Right on that button already spawn a tab and open the launcher;
    -- Middle maps to no action, so the event fires with nothing to override.
    -- Returning false stops WezTerm handling it afterwards.
    wezterm.on("new-tab-button-click", function(window, pane, button, _default)
        if button == "Middle" then
            window:perform_action(rename_action(), pane)
            return false
        end
        return true
    end)

    -- And from the command palette, for when the mouse is not to hand.
    wezterm.on("augment-command-palette", function()
        return {
            {
                brief = "Rename tab",
                icon = "md_rename_box",
                action = rename_action(),
            },
        }
    end)

end

return module
