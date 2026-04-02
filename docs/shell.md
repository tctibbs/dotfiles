# Shell

ZSH with Znap plugin manager, modern CLI aliases, and Starship prompt.

## Plugins

Loaded via [Znap](https://github.com/marlonrichert/zsh-snap) in `home/dot_zshrc`:

| Plugin | Purpose |
|--------|---------|
| `zsh-autocomplete` | Real-time type-ahead completion |
| `zsh-you-should-use` | Reminds you of aliases when typing full commands |
| `fast-syntax-highlighting` | Command syntax coloring |
| `zsh-history-substring-search` | Up/Down arrow searches history by partial input |

## Integrations

| Tool | What it does |
|------|-------------|
| `fzf` | Fuzzy finder keybindings (Ctrl+R history, Ctrl+T files) |
| `zoxide` | Smart `cd` — learns your most-used directories |
| `Starship` | Cross-shell prompt with git status, language versions |

---

## Aliases

Defined in `home/private_dot_config/zsh/aliash.zsh`. Each alias is conditional — only loads if the tool is installed.

### Modern Replacements

| Alias | Tool | Replaces |
|-------|------|----------|
| `ls`, `ll`, `la`, `lt`, `llt`, `ld`, `lm` | eza | `ls` (with icons, colors, tree view, sort-by-modified) |
| `cat` | bat | `cat` (syntax-highlighted, paged) |
| `du` | dust | `du` (visual disk usage) |
| `ps` | procs | `ps` (colorized process viewer) |

### AI

| Alias | Command |
|-------|---------|
| `cc` | `claude --dangerously-skip-permissions` |
| `ccc` | `claude --dangerously-skip-permissions -c` (continue) |
| `gf` | `gemini --model gemini-2.5-flash` |

### Utilities

| Alias/Function | Description |
|----------------|-------------|
| `y` | Yazi file manager — `cd`s to directory on exit |
| `onefetch` | Repo info with nerd font icons |
| `dbconfig` | Opens gobang database config in `$EDITOR` |
| `getcontext` | Dump project files as markdown for AI context ([details](cli-tools.md#getcontext)) |

---

## Starship Prompt

Configured in `home/private_dot_config/starship.toml`. Nord color palette.

**Left prompt**: OS icon → directory → git branch → git status → docker → jobs

**Right prompt**: language versions → hostname (SSH only) → battery → duration (if >2s)

### Directory Shortcuts

| Path | Display |
|------|---------|
| `~/Documents` | ` Documents` |
| `~/Downloads` | `󰉍 Downloads` |
| `~/Code` | ` Code` |
| `~/Work` | `󰒋 Work` |
| `~/.config` | ` Config` |

### Git Status Symbols

| Symbol | Meaning |
|--------|---------|
| `!` | Modified |
| `+` | Staged |
| `?` | Untracked |
| `✘` | Deleted |
| `=` | Conflicted |

---

## Exports

Defined in `home/private_dot_config/zsh/exports.zsh`:

- `HISTSIZE` / `SAVEHIST`: 5000
- `PATH`: `~/.local/bin` prepended
