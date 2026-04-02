# VS Code

Managed by chezmoi — settings and extensions are deployed automatically on `chezmoi apply`.

## What Gets Deployed

| File | Platform | Target |
|------|----------|--------|
| `settings.json.tmpl` | macOS | `~/Library/Application Support/Code/User/settings.json` |
| `settings.json.tmpl` | Linux | `~/.config/Code/User/settings.json` |
| `settings.json.tmpl` | Windows | `~/AppData/Roaming/Code/User/settings.json` |

---

## Theme & Appearance

Matches the terminal stack (WezTerm / Windows Terminal / tmux):

| Setting | Value |
|---------|-------|
| Color theme | Catppuccin Mocha (mauve accent, minimal workbench, neovim bracket mode) |
| File icons | Catppuccin Mocha |
| Product icons | Fluent Icons |
| Editor font | FiraCode Nerd Font Mono, 14pt, ligatures on, line height 1.6 |
| Terminal font | FiraCode Nerd Font Mono, 13pt, line cursor, blinking |
| Terminal colors | Full Catppuccin Mocha ANSI palette (matches WezTerm hex values) |

---

## Editor Behavior

| Setting | Value |
|---------|-------|
| Format on save | Yes (editor + notebooks) |
| Default formatter | Ruff |
| Bracket colorization | On |
| Semantic highlighting | On |
| Linked editing | On (auto-rename HTML tags) |
| Trim trailing whitespace | On |

---

## Clean UI

Visual noise is aggressively removed:

- No minimap, scrollbars, breadcrumbs, or rulers
- No indentation/bracket guides, glyph margin, or lightbulb
- No line highlight, sticky scroll, or occurrence highlights
- Whitespace only rendered in selection
- Smooth scrolling and cursor animation enabled

---

## Layout

| Setting | Value |
|---------|-------|
| Activity bar | Top |
| Sidebar | Right |
| Tabs | Multiple, shrink sizing, compact pinned |
| Tab close button | Hidden |
| Preview mode | Disabled (always open in full editor) |
| Window title | `{project} — {file}` |
| Menu bar | Toggle (hidden by default) |
| Command center | Off |
| Startup editor | None |

---

## Zen Mode

| Setting | Value |
|---------|-------|
| Full screen | Off (stays windowed) |
| Centered layout | On |
| Line numbers | Visible |
| Activity bar | Hidden |
| Tabs | Hidden |
| Notifications | Silenced |

---

## Error Lens

Inline diagnostics via [Error Lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens):

| Setting | Value |
|---------|-------|
| Style | Italic, light weight (300), message background |
| Levels | Errors and warnings only |
| Position | Active line, 40px margin |
| Delay | 500ms |
| Gutter icons | On |

---

## Chezmoi File Associations

The settings map dotfiles to correct language modes for syntax highlighting:

| Pattern | Language |
|---------|----------|
| `dot_zshrc`, `dot_bashrc`, `dot_profile`, `*.zsh`, `run_*.tmpl` | Shell |
| `dot_tmux*.conf` | Tmux |
| `dot_gitconfig*` | Properties |
| `dot_wezterm.lua`, `*.lua` | Lua |
| `.chezmoiignore` | Ignore |
| `.chezmoi*.yaml` / `.chezmoi*.toml` | YAML / TOML |

---

## Other Settings

| Setting | Value |
|---------|-------|
| Diff editor | Hide unchanged regions |
| PlantUML | Server rendering via plantuml.com |
| Remote SSH | `home-server` mapped to Linux |
| Jupyter | No kernel restart prompt |
| Dotfiles repo | `tctibbs/dotfiles` (for VS Code's built-in dotfiles sync) |

---

## Extensions

Installed automatically on **full profile** machines:

| Extension | Purpose |
|-----------|---------|
| `Catppuccin.catppuccin-vsc` | Color theme |
| `Catppuccin.catppuccin-vsc-icons` | File icons |
| `miguelsolorio.fluent-icons` | Product icons |
| `usernamehw.errorlens` | Inline diagnostics |
| `charliermarsh.ruff` | Python linter + formatter |
| `ms-vscode-remote.remote-ssh` | SSH remote development |
| `ms-vscode-remote.remote-ssh-edit` | SSH config editing |
| `ms-vscode-remote.remote-containers` | Dev containers |
| `ms-vscode-remote.remote-wsl` | WSL remote development |
| `ms-vscode.remote-explorer` | Remote connections sidebar |
| `jebbs.plantuml` | PlantUML diagram rendering |

Extensions only install when `code` is on PATH. Failures are non-fatal.

---

## Re-running Extension Install

Scripts run once per machine (tracked by content hash). To force a re-run:

```bash
chezmoi state delete-bucket --bucket=entryState && chezmoi apply
```

---

## Updating Settings

Always edit the `.tmpl` source, not the deployed file (chezmoi overwrites it on next apply):

```bash
chezmoi edit ~/.config/Code/User/settings.json   # opens the .tmpl in $EDITOR
chezmoi apply                                      # deploy the change
```
