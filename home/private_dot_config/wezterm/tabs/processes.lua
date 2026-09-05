-- Foreground process icons for tabs that are not running a coding agent.
--
-- Glyphs are referenced through wezterm.nerdfonts rather than pasted as raw
-- codepoints, so a wrong name is a visible nil at startup instead of a
-- mystery box in the tab bar.
--
-- Glyphs are also chosen for legibility at tab-bar size. md_console and
-- md_chart_box are both box outlines that read as tofu when small, which is
-- why shells use the >_ form and monitors use a dial.

local wezterm = require("wezterm")
local nf = wezterm.nerdfonts

local module = {}

module.fallback = nf.md_dots_horizontal

local icons = {
    zsh = nf.md_console_line,
    bash = nf.md_console_line,
    fish = nf.md_console_line,
    sh = nf.md_console_line,

    nvim = nf.md_book_open_variant,
    vim = nf.md_book_open_variant,
    vi = nf.md_book_open_variant,

    git = nf.md_git,
    lazygit = nf.md_git,

    node = nf.md_nodejs,
    npm = nf.md_nodejs,
    pnpm = nf.md_nodejs,

    python = nf.md_language_python,
    python3 = nf.md_language_python,
    pip = nf.md_language_python,
    uv = nf.md_language_python,

    docker = nf.md_docker,
    lazydocker = nf.md_docker,

    ssh = nf.md_ssh,

    btop = nf.md_speedometer,
    htop = nf.md_speedometer,
    top = nf.md_speedometer,

    cargo = nf.md_language_rust,
    rustc = nf.md_language_rust,
    go = nf.md_language_go,
    lua = nf.md_language_lua,

    make = nf.md_hammer_wrench,
    cmake = nf.md_hammer_wrench,
    brew = nf.md_beer,
    man = nf.md_help_circle_outline,
}

--- Icon for the first candidate key that names a known process.
--
-- PaneInformation.foreground_process_name is a lazily computed field and can
-- come back empty, in which case the tab title is often the process name
-- anyway ("zsh", "btop"). Trying both keeps the icon rather than silently
-- dropping to the fallback.
--
-- @param candidates table ordered list of strings, most trusted first.
--   Build it with only non-nil entries; ipairs stops at the first hole.
-- @return string a glyph, never nil
function module.icon_for(candidates)
    -- ipairs, not pairs: the candidates are ordered by confidence and pairs
    -- makes no ordering guarantee.
    for _, key in ipairs(candidates or {}) do
        if type(key) == "string" and key ~= "" then
            local icon = icons[key:lower()]
            if icon then
                return icon
            end
        end
    end
    return module.fallback
end

return module
