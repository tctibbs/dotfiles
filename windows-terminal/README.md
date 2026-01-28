# Windows Terminal Configuration

Windows Terminal settings matching the WezTerm configuration with Catppuccin Mocha theme.

## Installation

```powershell
.\install.ps1
```

The script will:
- Backup existing settings.json (timestamped)
- Install to Windows Terminal (stable)
- Install to Windows Terminal Preview (if present)

## What's Included

### Visual Settings
- **Color scheme**: Catppuccin Mocha (all 16 colors)
- **Font**: FiraCode Nerd Font, 13pt with ligatures
- **Cursor**: Bar cursor
- **Padding**: 8px window padding
- **Scrollback**: 10,000 lines
- **Bell**: Visual only (no audio)
- **Acrylic**: Enabled at 85% opacity

### Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+T` | New tab |
| `Ctrl+W` | Close tab |
| `Ctrl+Shift+\` | Vertical split |
| `Ctrl+Shift+-` | Horizontal split |
| `Ctrl+Shift+Arrow` | Navigate panes |
| `Ctrl+Shift+W` | Close pane |
| `Alt+1-5` | Switch tabs |
| `Ctrl+Enter` | Toggle fullscreen |
| `Ctrl+C` | Copy |
| `Ctrl+V` | Paste |
| `Ctrl+Shift+F` | Find |

## Requirements

- Windows Terminal (from Microsoft Store or winget)
- FiraCode Nerd Font: `winget install Nerd-Fonts.FiraCode`

## Feature Parity with WezTerm

| Feature | WezTerm | Windows Terminal | Status |
|---------|---------|------------------|--------|
| Catppuccin Mocha | Yes | Yes | Full |
| FiraCode Nerd Font 13pt | Yes | Yes | Full |
| Ligatures | Yes | Yes | Full |
| 8px padding | Yes | Yes | Full |
| 10,000 scrollback | Yes | Yes | Full |
| Bar cursor | Yes | Yes | Full |
| Visual bell | Yes | Yes | Full |
| Acrylic blur | Yes | Yes | Full |
| Pane splits | Yes | Yes | Full |
| Tab colors | Per-tab | Per-profile only | Partial |
| Auto-hide tab bar | Yes | No | Not supported |
| Process icons in tabs | Yes | No | Not supported |
| Powerline tab separators | Yes | No | Not supported |
