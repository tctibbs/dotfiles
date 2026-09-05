-- Claude Code — https://code.claude.com
--
-- Hooks: ~/.claude/settings.json. 33 lifecycle events.
-- Caveat: Claude Code hooks run without a controlling terminal, so they cannot
-- write to /dev/tty. wezterm-agent-state resolves the pane's tty by walking the
-- ancestor process chain instead. See docs/wezterm.md.
local p = require("palette")

return {
    id = "claude",
    name = "Claude Code",
    icon = "󰚩",
    color = p.peach,

    processes = { "claude" },

    -- Claude Code titles the tab with an LLM-generated session topic, so these
    -- only match the fallback string. Identity really comes from the user var.
    title_patterns = { "claude" },
}
