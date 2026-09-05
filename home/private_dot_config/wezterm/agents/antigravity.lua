-- Google Antigravity CLI — binary `agy`
--
-- Separate product from the Antigravity IDE. Hooks plus a `title.command`
-- script in ~/.gemini/antigravity-cli/settings.json. The status line payload
-- carries `tool_confirmation_pending`, which is what distinguishes "waiting on
-- you" from "finished" — `agent_state` alone does not.
local p = require("palette")

return {
    id = "antigravity",
    name = "Antigravity CLI",
    icon = "󱓞",
    color = p.mauve,

    processes = { "agy", "antigravity" },
    title_patterns = { "antigravity", "agy" },
}
