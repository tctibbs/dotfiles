-- OpenAI Codex CLI — https://github.com/openai/codex
--
-- Hooks: ~/.codex/hooks.json or [[hooks.Stop]] in ~/.codex/config.toml.
-- Requires a build with the hooks crate (rust-v0.115.0+); hook definitions must
-- be trusted on first run via the startup review or /hooks.
local p = require("palette")

return {
    id = "codex",
    name = "Codex CLI",
    icon = "󰧑",
    color = p.teal,

    processes = { "codex" },
    title_patterns = { "codex" },
}
