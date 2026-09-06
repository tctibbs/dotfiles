# WezTerm

GPU-accelerated terminal with modular Lua config. Entry point: `home/dot_wezterm.lua` loads modules from `home/private_dot_config/wezterm/`.

## Key Bindings

Platform-aware: `Cmd` on macOS, `Ctrl` on Windows/Linux.

### Tabs

| Key | Action |
|-----|--------|
| `Mod+T` | New tab |
| `Mod+W` | Close tab |
| `Mod+Shift+R` | Rename tab |
| Middle-click `+` | Rename tab |

Also in the command palette. An empty name clears the override, returning the
tab to tracking its program. Double-clicking a tab cannot be bound — WezTerm
hit-tests tab-bar items before consulting `mouse_bindings`, so the click never
reaches user config, and the new-tab button is the only tab-bar element that
emits a Lua event.

### Panes

| Key | Action |
|-----|--------|
| `Ctrl+Shift+\|` | Split horizontal |
| `Ctrl+Shift+_` | Split vertical |
| `Ctrl+Shift+W` | Close pane |
| `Ctrl+Shift+Arrow` | Navigate panes |

### Other

| Key | Action |
|-----|--------|
| `Mod+Enter` | Toggle fullscreen |
| `Ctrl+C` | Copy selection or send interrupt |
| `Ctrl+V` | Paste |
| `Ctrl+Shift+F5` | Reload config |
| `Ctrl+Shift+P` | Shell picker (WSL/PowerShell/Zsh/Bash) |

---

## Theme

**Catppuccin Mocha** — consistent with tmux, VS Code, and Windows Terminal.

| Setting | Value |
|---------|-------|
| Font | FiraCode Nerd Font Mono, 13pt |
| Ligatures | Contextual alternates, standard, discretionary |
| Background | `#1e1e2e` with optional wallpaper (15% brightness) |
| Cursor | Blinking bar, 500ms blink rate |
| Scrollback | 10,000 lines |
| Renderer | WebGpu |

---

## Tab Bar

Powerline-style, rendered by `tabs/init.lua`. Requires the retro tab bar
(`use_fancy_tab_bar = false`): the fancy bar draws its own chrome and
composites a close button over whatever `format-tab-title` returns, so per-tab
backgrounds cannot be controlled there.

Tabs not running a coding agent get an icon for their foreground process,
defined in `tabs/processes.lua`:

| Icon | Process |
|------|---------|
| `󰞷` | zsh, bash, fish, sh |
| `󱓷` | nvim, vim |
| `󰊢` | git, lazygit |
| `󰎙` | node, npm, pnpm |
| `󰌠` | python, pip, uv |
| `󰡨` | docker, lazydocker |
| `󰓅` | btop, htop, top |
| `󰣀` | ssh |
| `󱘗` `󰟓` `󰢱` | cargo, go, lua |
| `󱌣` `󰂘` `󰘥` | make, brew, man |
| `󰇘` | anything else |

Active tabs are blue (`#89b4fa`), inactive dark grey (`#313244`).

---

## Coding Agent Tabs

Tabs show which coding agent is running and what it is doing.

The working/idle/waiting signal also carries over to Windows Terminal via an
`OSC 9;4` progress ring — see [windows-terminal.md](windows-terminal.md). The
rich rendering below (icons, per-tab colour, status rollup) is WezTerm-only.

| State | Colour | Meaning |
|-------|--------|---------|
| working | `#f9e2af` yellow dot | agent is running |
| idle | `#a6e3a1` green dot | finished, nothing pending |
| waiting | `#f38ba8` red tab | blocked on you — the whole tab flips |

### Registered agents

| Agent | Binary | Icon | Colour |
|-------|--------|------|--------|
| Claude Code | `claude` | `󰚩` | `#fab387` peach |
| Codex CLI | `codex` | `󰧑` | `#94e2d5` teal |
| Copilot CLI | `copilot` | `󰊤` | `#74c7ec` sapphire |
| Antigravity CLI | `agy` | `󱓞` | `#cba6f7` mauve |

### Adding an agent

Drop a file in `~/.config/wezterm/agents/<id>.lua` and add its id to
`REGISTERED` in `agents/init.lua`. The contract:

```lua
local p = require("palette")
local nf = require("wezterm").nerdfonts

return {
    id = "myagent",             -- required, matches the agent_id user var
    name = "My Agent",          -- required
    icon = nf.md_robot,         -- required, one cell wide
    color = p.sapphire,         -- required, avoid the three state colours
    processes = { "myagent" },  -- optional, lowercase executable names
    title_patterns = { "my" },  -- optional, lowercase Lua patterns
}
```

Take colours from `palette.lua` and glyphs from `wezterm.nerdfonts` rather than
pasting values: an unknown glyph name is `nil`, which the validator reports by
file and field at startup. A malformed file is skipped with a warning rather
than breaking the tab bar.

### How state arrives

Detection precedence: the `agent_id` user var, then the foreground process
name, then title patterns. The first two are trusted and can drive state; a
title match earns only an icon, or any program could turn a tab red by printing
the right words. These states are advisory, not a security boundary — anything
a pane writes is attacker-influenced.

User variables live as long as the pane, so a tab identified by `agent_id`
keeps that identity until cleared; wire a session-end hook to
`wezterm-agent-state <id> clear` to avoid a stale icon. Process-name identity
needs no cleanup.

State comes from the `agent_state` user var, written by `wezterm-agent-state`:

```sh
wezterm-agent-state claude working
wezterm-agent-state claude clear
```

With no state reported, an unfocused agent tab whose active pane has unseen
output falls back to `waiting`, drawn with a smaller dot so a guess never looks
like a fact. No hook needed, but the tab must first be identified as an agent by
user variable or process name.

### Wiring each agent

| Agent | Where | Note |
|-------|-------|------|
| Claude Code | `hooks` in `~/.claude/settings.json` | hooks run with **no controlling terminal**; the helper walks the ancestor process chain to find the pane's tty |
| Codex CLI | `~/.codex/hooks.json` | needs a build with the hooks crate; definitions must be trusted on first run via the startup review or `/hooks` |
| Copilot CLI | `~/.copilot/hooks/*.json` | hooks share the CLI's shell, so `/dev/tty` works; write to the tty, never stdout — stdout is parsed as the hook's decision payload |
| Antigravity CLI | `title.command` in `~/.gemini/antigravity-cli/settings.json` | `tool_confirmation_pending` is what distinguishes "waiting" from "finished"; `agent_state` alone does not |

Map events to states like this: session start → `idle`, prompt submitted →
`working`, permission or approval requested → `waiting`, stop → `idle`,
session end → `clear`.

### Caveats

- `format-tab-title` is synchronous. `wezterm.run_child_process` inside it
  errors with `attempt to yield from outside a coroutine`, so state must
  arrive via user vars — nothing can be queried at render time.
- Inside tmux the escape needs the DCS passthrough wrapper and tmux needs
  `allow-passthrough on`. The helper handles the wrapper.
- `wezterm cli set-user-var` does not exist in any WezTerm version. User vars
  can only be set through the OSC 1337 escape.

---

## Platform Behavior

| Platform | Details |
|----------|---------|
| macOS | Native fullscreen, window blur, Alt sends regular characters |
| Windows | PowerShell default, launch menu (PS7/PS5/CMD), WSL auto-detected |
| Linux | `zsh --login` default |

---

## Remembering Directories

Every two minutes each tab's directory is written to
`~/.local/share/wezterm/tabs.json`. On the next launch those tabs reopen in the
same places, named after their directory. Delete the file to start clean.

Programs are not restarted, so resume the agent yourself:

```sh
claude --continue
codex resume
```

Nothing here knows which tool you were running, so nothing breaks when one of
them changes its CLI.

| | |
|---|---|
| Saved | one entry per tab: its working directory |
| Not saved | running programs, pane splits, scrollback, workspaces |
| Skipped | a directory that no longer exists opens the window at home, or a later tab wherever the window already is |

Launching with an explicit command (`wezterm start -- htop`) skips the restore.

---

## Config Modules

| File | Responsibility |
|------|---------------|
| `keys.lua` | Keybindings (platform-aware modifier) |
| `tabs/` | Tab rendering (`init.lua`) and process icons (`processes.lua`) |
| `theme.lua` | Colors, font, cursor, background, window chrome |
| `platform.lua` | OS detection, default shell, launch menu |
| `palette.lua` | Catppuccin Mocha values, the single source of colour |
| `text.lua` | Sanitises every title, process name and user-var value |
| `agents/` | Agent registry (`init.lua`), canonical states (`state.lua`), one file per agent |
| `status.lua` | Right-status rollup of agent states across the window |
| `sessions.lua` | Reopens tabs in the directories they were in |
