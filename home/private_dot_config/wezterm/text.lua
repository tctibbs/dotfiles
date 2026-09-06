-- Text normalisation for titles, process names and user-var values.
--
-- Everything here matches explicit ASCII ranges only. Lua's %c, %s and
-- string.lower are byte-oriented and locale-dependent: in the GUI they touch
-- bytes 0x80-0x9F, which are UTF-8 continuation bytes, so replacing one splits
-- the character. Every wezterm.* call then throws on the result and the tab
-- falls back to WezTerm's default title — a pane titled "✳ Claude Code"
-- reproduces it. No byte below 0x80 can appear inside a multi-byte sequence,
-- so explicit ranges are safe.

local wezterm = require("wezterm")

local module = {}

-- Zero-width and bidi marks, as UTF-8 byte sequences: U+200B, U+200E, U+200F,
-- U+2028..U+202E, U+2060..U+2064, U+FEFF.
--
-- U+200C and U+200D are deliberately absent: they are joiners, so removing one
-- splits a grapheme and makes the string wider, not narrower — a family emoji
-- goes from 2 cells to 8. ZWNJ is also meaningful in Persian and Devanagari.
local INVISIBLE = {
    "\226\128\139", "\226\128\142", "\226\128\143",
    "\226\128\168", "\226\128\169", "\226\128\170", "\226\128\171", "\226\128\172",
    "\226\128\173", "\226\128\174", "\226\129\160", "\226\129\161", "\226\129\162",
    "\226\129\163", "\226\129\164", "\239\187\191",
}

--- Lowercase ASCII letters only, leaving every other byte untouched.
-- string.lower maps bytes through tolower(), which under some locales alters
-- bytes above 0x7F and corrupts UTF-8.
function module.ascii_lower(s)
    if type(s) ~= "string" then
        return ""
    end
    return (s:gsub("[A-Z]", function(c)
        return string.char(c:byte() + 32)
    end))
end

--- Strip anything that would not occupy a predictable cell.
--
-- Titles come from OSC 0 and are untrusted. This is the single gate they pass
-- through: the result is valid UTF-8 of at least one cell, so callers can treat
-- "" as "no usable title" and fall through.
--
-- The width check at the end is what makes that guarantee hold. INVISIBLE
-- cannot be exhaustive — U+2066..U+2069, U+00AD and U+FE0F are not in it — and
-- a title of only such codepoints would stay non-empty while rendering nothing.
-- Measuring closes the class instead of chasing codepoints.
function module.sanitize(s)
    if type(s) ~= "string" or s == "" then
        return ""
    end

    s = s:gsub("[\0-\31\127]", " ")
    for _, seq in ipairs(INVISIBLE) do
        s = s:gsub(seq, "")
    end
    s = (s:gsub(" +", " "):gsub("^ +", ""):gsub(" +$", ""))

    -- column_width raises on invalid UTF-8, which is exactly the input we want
    -- to reject, so a failure here is treated the same as an unusable title.
    local ok, width = pcall(wezterm.column_width, s)
    if not ok or width == 0 then
        return ""
    end

    return s
end

--- Bare lowercase executable name from a path, without a Windows extension.
-- Agent `processes` entries are bare lowercase names, so claude.exe has to
-- reduce to "claude" or nothing matches on Windows.
function module.basename(path)
    if type(path) ~= "string" or path == "" then
        return nil
    end

    local name = module.ascii_lower(path:gsub("(.*[/\\])(.*)", "%2"))
    name = name:gsub("%.exe$", "")

    if name == "" then
        return nil
    end
    return name
end

return module
