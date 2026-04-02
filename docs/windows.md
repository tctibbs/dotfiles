# Windows

PowerShell profile and Windows Terminal settings, deployed by chezmoi on Windows machines.

## PowerShell Profile

`home/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`

### Tool Initialization

| Tool | What it does |
|------|-------------|
| Starship | Prompt (same config as ZSH) |
| Zoxide | Smart `cd` |
| fnm | Node.js version manager |
| PSFzf | Fuzzy history (`Ctrl+R`) and file finder (`Ctrl+F`) |
| Terminal-Icons | File/folder icons in `ls` output |

### PSReadLine

- **Tab**: Menu-complete (cycle through options)
- **Up/Down**: History search by current input
- **Ctrl+D**: Delete character
- **Ctrl+W**: Delete word
- Predictive IntelliSense from history

### Quick Navigation

| Command | Destination |
|---------|-------------|
| `..` / `...` / `....` | Parent / grandparent / great-grandparent |
| `~` | Home directory |
| `desktop` / `downloads` / `docs` | User folders |

---

## PowerShell Aliases

`home/Documents/PowerShell/aliases.ps1`

Same modern CLI replacements as ZSH (eza, bat, dust, procs), plus Windows-specific additions:

| Alias | Description |
|-------|-------------|
| `proc` | procs (uses `proc` instead of `ps` to avoid PowerShell conflict) |
| `lg` | lazygit |
| `lzd` | lazydocker |
| `gst`, `gco`, `gcm`, `gpl`, `gps`, `glog` | Git shortcuts |
| `dps`, `dpsa`, `di`, `dex`, `dlog`, `dstop`, `drm`, `drmi` | Docker shortcuts |

### Utility Functions

| Function | Description |
|----------|-------------|
| `filesize <path>` | Total size of directory |
| `Find-LargeFiles <n>` | Top N largest files |
| `ping-google` | Quick connectivity check |
| `Test-Port <host> <port>` | Check port availability |
| `venv` | Activate Python `.venv` |
| `http-server` | Python HTTP server on port 8000 |

---

## Windows Terminal

Settings deployed to `AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/settings.json`.

Catppuccin Mocha theme with acrylic blur and background image, matching the WezTerm config.
