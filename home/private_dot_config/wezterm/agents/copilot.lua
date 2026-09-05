-- GitHub Copilot CLI — https://github.com/github/copilot-cli
--
-- The standalone agentic CLI (binary `copilot`), not the older `gh copilot`
-- extension. Hooks: ~/.copilot/hooks/*.json, 17 lifecycle events. Hooks run in
-- the same shell as the CLI, so they can write to /dev/tty directly.
-- Set `updateTerminalTitle` to false to stop it overwriting a title you set.
local p = require("palette")
local nf = require("wezterm").nerdfonts

return {
    id = "copilot",
    name = "Copilot CLI",
    icon = nf.md_github,
    color = p.sapphire,

    processes = { "copilot" },
    title_patterns = { "copilot" },
}
