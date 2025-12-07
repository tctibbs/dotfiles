# Tmux Configuration

Cross-platform tmux setup with modern plugin stack, AI integration, and floating scratchpads.

## Installation

```bash
./install.sh
```

This will:
1. Install tmux if not present
2. Install TPM (Tmux Plugin Manager)
3. Symlink all configuration files
4. Install plugins automatically
5. Install optional tools (lazygit, pipes.sh, fzf)

## Architecture

```
~/.tmux.conf           Main config (sources OS-specific files)
~/.tmux.mac.conf       macOS: pbcopy, iTerm2 passthrough
~/.tmux.linux.conf     Linux: xclip/wl-copy/WSL2 clipboard
~/.tmux/plugins/       TPM-managed plugins
```

## Key Bindings

**Prefix: `Ctrl-a`** (not Ctrl-b)

### Navigation
| Binding | Action |
|---------|--------|
| `Alt + Arrow` | Navigate panes (no prefix) |
| `Alt + 1-5` | Switch to window 1-5 |
| `Prefix + \|` | Split horizontal |
| `Prefix + -` | Split vertical |
| `Alt+Shift + Arrow` | Resize pane |

### Scratchpads
| Binding | Action |
|---------|--------|
| `Prefix + g` | LazyGit popup (current directory) |
| `Prefix + a` | Claude AI popup (current directory) |
| `Prefix + b` | btop system monitor |
| `Prefix + n` | Notes (nano ~/.tmux-notes.md) |

### Power User
| Binding | Action |
|---------|--------|
| `Prefix + F` | tmux-thumbs: quick-copy hints (URLs, paths, hashes) |
| `Prefix + f` | tmux-fzf: fuzzy-find windows, panes, commands |
| `Prefix + s` | Session browser (sessionx) |

### Session Management
| Binding | Action |
|---------|--------|
| `Prefix + Ctrl-s` | Save session (resurrect) |
| `Prefix + Ctrl-r` | Restore session (resurrect) |
| `Prefix + r` | Reload config |
| `Prefix + I` | Install/update plugins |
| `Prefix + U` | Update plugins |

## Plugins

| Plugin | Purpose |
|--------|---------|
| [tpm](https://github.com/tmux-plugins/tpm) | Plugin manager |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sensible defaults |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | Universal clipboard |
| [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) | Fuzzy session browser |
| [tmux2k](https://github.com/2KAbhishek/tmux2k) | Status bar (Catppuccin theme) |
| [tmux-tpad](https://github.com/Subbeh/tmux-tpad) | Floating scratchpads |
| [tmux-thumbs](https://github.com/fcsonline/tmux-thumbs) | Vimium-style quick copy |
| [tmux-fzf](https://github.com/sainnhe/tmux-fzf) | Fuzzy finder for tmux |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Session save/restore |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save (15 min) & auto-restore |

## Status Bar

Powered by tmux2k with Catppuccin theme:
- **Left**: git branch, CPU, RAM
- **Right**: battery, network, time, prefix indicator

Prefix indicator shows `^A` in pink when prefix is pressed.

## Features

- **Cross-platform clipboard**: Auto-detects pbcopy (macOS), xclip/wl-copy (Linux), clip.exe (WSL2)
- **iTerm2 integration**: Image passthrough, window titles
- **Screensaver**: pipes.sh after 5 minutes idle
- **Vi mode**: Copy with `v` to select, `y` to yank
- **Mouse support**: Enabled
- **Session persistence**: Auto-saves every 15 min, auto-restores on start

## Manual Plugin Install

If plugins don't auto-install:
```
tmux
<Prefix> + I
```

## Updating Plugins

```
<Prefix> + U
```
