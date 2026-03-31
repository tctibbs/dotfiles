# VS Code

Managed by chezmoi — settings, custom CSS, and extensions are deployed automatically on `chezmoi apply`.

## What Gets Deployed

| File | Platform | Target |
|------|----------|--------|
| `settings.json.tmpl` | Linux | `~/.config/Code/User/settings.json` |
| `custom.css` | Linux | `~/.config/Code/User/custom.css` |
| `settings.json.tmpl` | Windows | `~/AppData/Roaming/Code/User/settings.json` |
| `custom.css` | Windows | `~/AppData/Roaming/Code/User/custom.css` |

> **macOS**: Extensions install automatically but settings aren't deployed (VS Code uses `~/Library/Application Support/Code/User/`).

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

## Custom CSS

The [Custom CSS and JS Loader](https://marketplace.visualstudio.com/items?itemName=be5invis.vscode-custom-css) extension applies `custom.css` for UI polish not achievable through settings alone:

| Tweak | Effect |
|-------|--------|
| Floating command palette | Centered on screen at 200px from top, rounded corners, drop shadow |
| Rounded active tab | 6px radius, no top border accent stripe |
| Compact sidebar headers | Smaller font, heavier weight, wider letter-spacing |
| Rounded list rows | 4px radius on sidebar tree items |

### Activation (one-time per machine)

After `chezmoi apply`, VS Code needs to be told to load the CSS:

1. **Restart VS Code fully** (not just reload window)
2. `Ctrl+Shift+P` → **Enable Custom CSS and JS Loader**
3. Restart again when prompted
4. A yellow "corrupt installation" warning appears in the title bar — click the gear → **Don't Show Again**

> This warning is expected and harmless. VS Code flags any binary modification, including CSS injection.

---

## Extensions

Installed automatically by the `run_once_before_install-packages` scripts on **full profile** machines:

| Extension | Purpose |
|-----------|---------|
| `Catppuccin.catppuccin-vsc` | Color theme |
| `Catppuccin.catppuccin-vsc-icons` | File icons |
| `miguelsolorio.fluent-icons` | Product icons (toolbar, activity bar) |
| `be5invis.vscode-custom-css` | Loads `custom.css` |
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

## How the CSS Path Works

`vscode_custom_css.imports` uses a chezmoi template variable so the absolute path resolves at deploy time — no manual editing required:

**Linux** (`private_dot_config/Code/User/settings.json.tmpl`):
```
"file:///{{ .chezmoi.homeDir }}/.config/Code/User/custom.css"
```

**Windows** (`AppData/Roaming/Code/User/settings.json.tmpl`):
```
"file:///{{ .chezmoi.homeDir | replace "\\" "/" }}/AppData/Roaming/Code/User/custom.css"
```

The backslash-to-forward-slash replacement handles Windows paths in `file:///` URIs.

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
