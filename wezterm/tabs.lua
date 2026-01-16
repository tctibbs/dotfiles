-- Tab formatting configuration
-- Custom tab titles with process icons and powerline separators

local module = {}

-- Process icon mapping (Nerd Font icons)
local process_icons = {
    ["zsh"] = "󰆍",
    ["bash"] = "󰆍",
    ["fish"] = "󰆍",
    ["sh"] = "󰆍",
    ["nvim"] = "󰕷",
    ["vim"] = "󰕷",
    ["vi"] = "󰕷",
    ["lazygit"] = "󰊢",
    ["git"] = "󰊢",
    ["node"] = "󰎙",
    ["npm"] = "󰎙",
    ["python"] = "󰌠",
    ["python3"] = "󰌠",
    ["pip"] = "󰌠",
    ["docker"] = "󰡨",
    ["lazydocker"] = "󰡨",
    ["ssh"] = "󰣀",
    ["btop"] = "󰍛",
    ["htop"] = "󰍛",
    ["top"] = "󰍛",
    ["cargo"] = "",
    ["rustc"] = "",
    ["go"] = "",
    ["make"] = "󰣪",
    ["cmake"] = "󰣪",
    ["lua"] = "󰢱",
    ["ruby"] = "",
    ["brew"] = "󱄖",
    -- AI Agents
    ["claude"] = "󰚩",
    ["gemini"] = "󰊭",
    ["codex"] = "󰧑",
}

local default_icon = "󰅬"

-- AI agent patterns to detect from title (case-insensitive)
local ai_patterns = {
    { pattern = "claude", icon = "󰚩" },
    { pattern = "gemini", icon = "󰊭" },
    { pattern = "codex", icon = "󰧑" },
}

-- Powerline separators
local SOLID_LEFT_ARROW = ""
local SOLID_RIGHT_ARROW = ""

-- Get the process name from pane
local function get_process(tab)
    local process_name = tab.active_pane.foreground_process_name
    if process_name then
        -- Extract just the executable name
        process_name = process_name:gsub("(.*/)(.*)", "%2")
    end
    return process_name or "shell"
end

-- Get icon for process, checking title for AI agents
local function get_icon(process_name, title)
    -- First check if title contains AI agent names
    if title then
        local lower_title = title:lower()
        for _, agent in ipairs(ai_patterns) do
            if lower_title:find(agent.pattern) then
                return agent.icon
            end
        end
    end
    return process_icons[process_name] or default_icon
end

-- Truncate title to max length
local function truncate(str, max_len)
    if #str > max_len then
        return str:sub(1, max_len - 1) .. "…"
    end
    return str
end

-- Get a clean title (directory or process)
local function get_title(tab)
    local title = tab.tab_title
    if title and #title > 0 then
        return title
    end

    -- Use active pane title
    local pane_title = tab.active_pane.title
    if pane_title then
        -- Clean up common patterns
        pane_title = pane_title:gsub("^Copy mode: ", "")
        return pane_title
    end

    return get_process(tab)
end

function module.apply(config, wezterm)
    -- Format tab title event
    wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
        local process = get_process(tab)
        local title = get_title(tab)
        local icon = get_icon(process, title)

        -- Truncate title to fit (accounting for icon and spacing)
        local available_width = max_width - 4 -- icon + spaces
        title = truncate(title, available_width)

        -- Colors from Catppuccin Mocha
        local background = "#313244"
        local foreground = "#cdd6f4"

        if tab.is_active then
            background = "#89b4fa"
            foreground = "#1e1e2e"
        elseif hover then
            background = "#45475a"
        end

        local edge_background = "#1e1e2e"

        return {
            { Background = { Color = edge_background } },
            { Foreground = { Color = background } },
            { Text = SOLID_LEFT_ARROW },
            { Background = { Color = background } },
            { Foreground = { Color = foreground } },
            { Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
            { Text = " " .. icon .. " " .. title .. " " },
            { Background = { Color = edge_background } },
            { Foreground = { Color = background } },
            { Text = SOLID_RIGHT_ARROW },
        }
    end)
end

return module
