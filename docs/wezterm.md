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

Powerline-style with process-aware icons (Nerd Font):

| Process | Icon |
|---------|------|
| zsh, bash | `󰆍` |
| nvim, vim | `󰕷` |
| git, lazygit | `󰊢` |
| node, npm | `󰎙` |
| python | `󰌠` |
| docker | `󰡨` |
| claude | `󰚩` |
| gemini | `󰊭` |

Active tabs are blue (`#89b4fa`), inactive tabs are dark gray (`#313244`).

---

## Platform Behavior

| Platform | Details |
|----------|---------|
| macOS | Native fullscreen, window blur, Alt sends regular characters |
| Windows | PowerShell default, launch menu (PS7/PS5/CMD), WSL auto-detected |
| Linux | `zsh --login` default |

---

## Config Modules

| File | Responsibility |
|------|---------------|
| `keys.lua` | Keybindings (platform-aware modifier) |
| `tabs.lua` | Tab formatting, process icons, powerline arrows |
| `theme.lua` | Colors, font, cursor, background, window chrome |
| `platform.lua` | OS detection, default shell, launch menu |
