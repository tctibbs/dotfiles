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

Everything matches the terminal stack (WezTerm / Windows Terminal):

- **Color theme**: [Catppuccin Mocha](https://github.com/catppuccin/vscode) with mauve accent, `minimal` workbench mode
- **Icons**: [Catppuccin Mocha Icons](https://github.com/catppuccin/vscode-icons) + [Fluent Icons](https://marketplace.visualstudio.com/items?itemName=miguelsolorio.fluent-icons) for product icons
- **Font**: FiraCode Nerd Font Mono, size 14, ligatures on
- **Terminal font**: FiraCode Nerd Font Mono, size 13, line cursor
- **Terminal colors**: Catppuccin Mocha palette (identical hex values to WezTerm/Windows Terminal)
- **Layout**: Activity bar at top, sidebar on right, no minimap, no scrollbars, compact tabs

---

## Extensions

Installed automatically by the `run_once_before_install-packages` scripts on **full profile** machines:

| Extension | Purpose |
|-----------|---------|
| `Catppuccin.catppuccin-vsc` | Color theme |
| `Catppuccin.catppuccin-vsc-icons` | File icons |
| `miguelsolorio.fluent-icons` | Product icons (toolbar, activity bar) |
| `usernamehw.errorlens` | Inline diagnostics on the problem line |
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

Install scripts run once per machine (tracked by content hash). To force a re-run:

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
