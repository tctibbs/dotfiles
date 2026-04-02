# Tmux

Prefix: **Ctrl+a**. Mouse enabled, vi copy mode, 10k scrollback.

## Key Bindings

### Panes & Windows

| Key | Action |
|-----|--------|
| `prefix \|` | Split horizontal |
| `prefix -` | Split vertical |
| `prefix c` | New window (current path) |
| `Alt+Arrow` | Switch pane (no prefix) |
| `Alt+1-5` | Switch to window 1-5 |
| `Alt+Shift+Arrow` | Resize pane by 5 |
| `prefix r` | Reload config |

### Popup Scratchpads

Floating overlays via [tmux-tpad](https://github.com/5nik7/tmux-tpad):

| Key | Tool | Size |
|-----|------|------|
| `prefix g` | LazyGit | 85% |
| `prefix a` | Claude Code | 80% |
| `prefix b` | btop | 90% |
| `prefix n` | Notes (nano) | 70% |
| `prefix L` | Screensaver | 80% |

### Session Management

| Key | Action |
|-----|--------|
| `prefix s` | Session picker (tmux-sessionx + zoxide) |
| `prefix f` | Fuzzy finder (tmux-fzf) |

---

## Plugins

Managed by [TPM](https://github.com/tmux-plugins/tpm), installed via `run_onchange_after_setup-tmux.sh`:

| Plugin | Purpose |
|--------|---------|
| `tmux-sensible` | Sensible defaults |
| `tmux-yank` | System clipboard integration |
| `tmux-sessionx` | Session picker with zoxide |
| `tmux-fzf` | Fuzzy finder for sessions/windows/panes |
| `tmux-tpad` | Floating popup scratchpads |
| `tmux-resurrect` | Save/restore sessions across restarts |
| `tmux-continuum` | Auto-save every 15s, restore on attach |
| `tmux2k` | Status bar (git, cpu, ram, battery, network, time) |

---

## Theme

Catppuccin Mocha. Status bar powered by tmux2k:

- **Left**: working directory, git branch, CPU, RAM
- **Right**: battery, network, time (24h)

---

## Platform Configs

| File | What it adds |
|------|-------------|
| `dot_tmux.mac.conf` | Clipboard via `pbcopy`, iTerm2 image passthrough |
| `dot_tmux.linux.conf` | Clipboard auto-detection: Wayland (`wl-copy`), X11 (`xclip`), WSL (`clip.exe`) |
