# CLI Tools

Installed automatically by chezmoi on first run. Each tool has a `command -v` guard so re-runs skip already-installed tools.

## Install Scripts

| Script | What it installs |
|--------|-----------------|
| `00-install-base` | Homebrew (macOS), apt base packages (Linux) |
| `01-install-cli-tools` | All CLI tools below |
| `02-install-gui-apps` | Fonts, WezTerm, VS Code extensions (full profile only) |

### Install Methods by Platform

| Platform | Method |
|----------|--------|
| macOS | Homebrew (`brew install`) |
| Linux | GitHub release binaries → `~/.local/bin`, plus apt, cargo, npm |
| Windows | Scoop / winget / manual |

---

## Tool List

### File & Directory

| Tool | Description |
|------|-------------|
| [eza](https://github.com/eza-community/eza) | Modern `ls` with icons, colors, tree view |
| [bat](https://github.com/sharkdp/bat) | `cat` with syntax highlighting and paging |
| [fd](https://github.com/sharkdp/fd) | Fast, user-friendly `find` |
| [dust](https://github.com/bootandy/dust) | Visual disk usage analyzer |
| [yazi](https://github.com/sxyazi/yazi) | Terminal file manager with previews |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder for files, history, everything |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` that learns your habits |

### Git & Development

| Tool | Description |
|------|-------------|
| [delta](https://github.com/dandavison/delta) | Syntax-aware diff pager |
| [difftastic](https://github.com/Wilfred/difftastic) | Structural, AST-aware diffs |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | Terminal UI for docker |
| [dops](https://github.com/Mikescher/better-docker-ps) | Better `docker ps` output |
| [onefetch](https://github.com/o2sh/onefetch) | Git repo info display |

### System & Monitoring

| Tool | Description |
|------|-------------|
| [procs](https://github.com/dalance/procs) | Modern `ps` with color and layout |
| [btop](https://github.com/aristocratos/btop) | Resource monitor with charts |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | System info display |
| [tldr](https://github.com/dbrgn/tealdeer) | Simplified command help |

### Database

| Tool | Description |
|------|-------------|
| [pgcli](https://github.com/dbcli/pgcli) | PostgreSQL CLI with auto-completion |
| [mycli](https://github.com/dbcli/mycli) | MySQL CLI with auto-completion |
| [litecli](https://github.com/dbcli/litecli) | SQLite CLI with auto-completion |
| [gobang](https://github.com/TaKO8Ki/gobang) | Database TUI for multiple engines |

### AI & Documentation

| Tool | Description |
|------|-------------|
| [repomix](https://github.com/yamadashy/repomix) | Pack repo into AI-friendly file |
| [mcat](https://github.com/Skardyy/mcat) | Render markdown in terminal |
| [treemd](https://github.com/Skardyy/treemd) | Generate markdown directory trees |

### Prompt & Shell

| Tool | Description |
|------|-------------|
| [starship](https://starship.rs) | Cross-shell prompt |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |

---

## Getcontext

Custom utility (`home/private_dot_local/private_bin/executable_getcontext.zsh`) that dumps project files as markdown blocks — useful for providing codebase context to AI tools.

### Usage

```bash
getcontext python              # dump Python files in current directory
getcontext react -d src        # dump React files in src/
getcontext -e py,toml          # dump by custom extensions
getcontext rust --dry-run      # list files without contents
```

### Helper Functions

| Function | Description |
|----------|-------------|
| `getcontext-save <file>` | Save output to a file |
| `getcontext-copy` | Copy output to clipboard (auto-detects pbcopy/wl-copy/xclip/clip.exe) |

### Language Profiles

`python`, `javascript`, `typescript`, `node`, `react`, `rust`, `go`, `java`, `web`

### Options

| Flag | Description |
|------|-------------|
| `-e` | Custom file extensions |
| `-d` | Restrict to specific directories (repeatable) |
| `-m` | Max file count threshold (default 400) |
| `-y` | Skip confirmation prompt |
| `--dry-run` | List matching files only |

---

## Re-running Installs

Scripts run once per machine (tracked by content hash). To force a re-run:

```bash
chezmoi state delete-bucket --bucket=entryState && chezmoi apply
```
