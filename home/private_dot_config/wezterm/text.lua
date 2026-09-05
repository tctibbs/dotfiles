-- Text normalisation for titles, process names and user-var values.
--
-- Everything here is deliberately ASCII-only in what it MATCHES, because Lua's
-- string library is byte-oriented and its character classes and case functions
-- are locale-dependent. Under the locale the WezTerm GUI runs in, %c and %s
-- match bytes 0x80-0x9F, which are UTF-8 CONTINUATION bytes — replacing one
-- splits the character and produces invalid UTF-8. Any wezterm.* call given
-- that string then throws, format-tab-title fails, and the tab silently falls
-- back to WezTerm's default title. A pane titled "✳ Claude Code" reproduces it.
--
-- Matching only explicit ASCII ranges is safe: no byte in 0x00-0x7F can appear
-- inside a multi-byte UTF-8 sequence.

local wezterm = require("wezterm")

local module = {}

-- Zero-width and bidi format characters, as their UTF-8 byte sequences:
-- U+200B..U+200F, U+2028..U+202E, U+2060..U+2064, U+FEFF. These occupy no
-- cell but keep a string non-empty, which would defeat the "is this title
-- useful" checks in the tab bar.
local INVISIBLE = {
    "\226\128\139", "\226\128\140", "\226\128\141", "\226\128\142", "\226\128\143",
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
-- A program can put arbitrary bytes in OSC 0, so titles are untrusted input.
-- This is the single gate every title passes through, and it guarantees the
-- result is valid UTF-8 that occupies at least one cell — callers can then
-- treat "" as "no usable title" and fall through to the next candidate.
--
-- Stripping INVISIBLE by hand is not enough on its own: it removes marks from
-- the middle of an otherwise visible title, but the zero-width set is open
-- ended (U+2066..U+2069, U+00AD, U+FE0F and others are not in it). A title
-- made only of such codepoints would stay non-empty while rendering nothing,
-- producing a nameless and, at some widths, zero-column tab. Measuring closes
-- the whole class rather than chasing codepoints.
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
