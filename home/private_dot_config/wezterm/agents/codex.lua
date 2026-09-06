-- OpenAI Codex CLI — https://github.com/openai/codex
--
-- Hooks: ~/.codex/hooks.json or [[hooks.Stop]] in ~/.codex/config.toml.
-- Requires a build with the hooks crate (rust-v0.115.0+); hook definitions must
-- be trusted on first run via the startup review or /hooks.
local p = require("palette")
local nf = require("wezterm").nerdfonts

return {
    id = "codex",
    name = "Codex CLI",
    icon = nf.md_brain,
    color = p.teal,

    processes = { "codex" },
    title_patterns = { "codex" },
}
