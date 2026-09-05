-- OpenAI Codex CLI — https://github.com/openai/codex
--
-- Hooks: ~/.codex/hooks.json or [[hooks.Stop]] in ~/.codex/config.toml.
-- Requires a build with the hooks crate (rust-v0.115.0+); hook definitions must
-- be trusted on first run via the startup review or /hooks.
return {
    id = "codex",
    name = "Codex CLI",
    icon = "󰧑",
    color = "#94e2d5", -- teal

    processes = { "codex" },
    title_patterns = { "codex" },
}
