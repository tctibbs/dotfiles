# Dotfiles

![Terminal Screenshot](assets/terminal_screenshot.png)

Personal configuration for a consistent dev environment across macOS, Linux, and Windows.

## Features

### Terminal Stack
- **WezTerm** - GPU-accelerated terminal with Catppuccin theme, fancy tabs, background image
- **Windows Terminal** - Native Windows terminal with matching Catppuccin theme, acrylic blur, background image
- **Tmux** - Terminal multiplexer with session persistence and popup scratchpads
- **Starship** - Cross-shell prompt with git integration and directory icons
- **Zsh** - Shell with modern CLI tool aliases

### What's Included

| Category | Tools |
|----------|-------|
| Terminal | WezTerm, Windows Terminal, tmux, starship |
| Shell | zsh, aliases, exports |
| CLI Tools | eza, bat, dust, procs, fd, fzf, btop, tldr, fastfetch |
| Git | Conditional identity (personal/work), delta diffs |
| AI | Claude Code & Gemini CLI aliases |

## Installation

### Linux / macOS

```bash
git clone https://github.com/tctibbs/dotfiles.git
cd dotfiles
./setup.sh
```

### Windows

```powershell
# In PowerShell (Administrator recommended for symlinks)
git clone https://github.com/tctibbs/dotfiles.git
cd dotfiles
.\setup.ps1
```

**Windows Notes:**
- **Symlinks**: Enable Developer Mode in Windows Settings or run PowerShell as Administrator to create symlinks. If symlinks fail, files will be copied automatically with a warning.
- **Package Manager**: Requires [winget](https://aka.ms/getwinget) (built into Windows 11, available for Windows 10).
- **Tools**: Installs modern CLI tools via winget and cargo (Rust tools like eza, dust, yazi).
- **Restart Required**: Restart PowerShell after installation to load the new configuration.

**What Gets Installed on Windows:**
- WezTerm with Catppuccin theme and background image
- Windows Terminal with matching Catppuccin theme, acrylic blur, background image
- Starship prompt
- PowerShell profile with modern CLI aliases
- Git configuration
- Common CLI tools: eza, bat, dust, fd, fzf, zoxide, tldr, yazi, and more

## Key Bindings

### Tmux (Prefix: Ctrl-a)

| Key | Action |
|-----|--------|
| `\|` | Split horizontal |
| `-` | Split vertical |
| `g` | LazyGit popup |
| `a` | Claude AI popup |
| `b` | btop popup |
| `s` | Session picker |

### WezTerm

| Key | Action |
|-----|--------|
| `Cmd+Enter` | Toggle fullscreen |
| `Cmd+T` | New tab |
| `Cmd+W` | Close tab |
| `Cmd+Shift+R` | Rename tab |
| `Ctrl+Shift+\|` | Split horizontal |
| `Ctrl+Shift+_` | Split vertical |

### Windows Terminal

| Key | Action |
|-----|--------|
| `Ctrl+Enter` | Toggle fullscreen |
| `Ctrl+T` | New tab |
| `Ctrl+W` | Close tab |
| `Alt+1-5` | Switch to tab 1-5 |
| `Ctrl+Shift+\` | Split vertical |
| `Ctrl+Shift+-` | Split horizontal |
| `Ctrl+Shift+Arrow` | Navigate panes |
| `Ctrl+Shift+W` | Close pane |

## CLI Tool Aliases

| Tool   | Replaces     | Description                                     |
|--------|--------------|-------------------------------------------------|
| `eza`  | `ls`         | Modern replacement with color, icons, tree view |
| `bat`  | `cat`        | Syntax-highlighted file viewer with pager       |
| `dust` | `du`         | Visual disk usage analyzer                      |
| `procs`| `ps`         | Improved process viewer with color and layout   |
| `fd`   | `find`       | Fast, user-friendly file search tool            |
| `tldr` | `man`        | Simplified community-driven command help        |
| `btop` | `htop`/`top` | Resource monitor with charts and themes         |
| `pgcli`| `psql`       | PostgreSQL CLI with auto-completion             |
| `mycli`| `mysql`      | MySQL CLI with auto-completion                  |
| `litecli`| `sqlite3`  | SQLite CLI with auto-completion                 |
| `gobang`| -           | Database TUI for multiple databases             |
| `fzf`  | -            | Fuzzy finder for command-line                   |
| `fastfetch` | `neofetch` | Fast system info display                    |
| `repomix` | -            | Pack repo into AI-friendly file             |
| `mcat`  | -              | Render markdown in terminal                   |
| `treemd`| `tree`         | Generate markdown directory trees             |
| `onefetch`| -            | Git repo info display (like neofetch for repos)|
| `yazi`  | -              | Terminal file manager with previews             |

## AI CLI Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `cc`  | `claude --dangerously-skip-permissions` | Claude Code |
| `ccc` | `claude --dangerously-skip-permissions -c` | Claude Code continue |
| `gf`  | `gemini --model gemini-2.5-flash` | Gemini Flash |

## Documentation

- [VSCode Integration](docs/vscode.md) - Auto-deploy dotfiles on remote SSH connections

