# WezTerm Installation Script for Windows
# ========================================
# Equivalent to install.sh for Unix systems
# Run in PowerShell: .\install.ps1

$ErrorActionPreference = "Stop"

# Colors
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) { Write-Output $args }
    $host.UI.RawUI.ForegroundColor = $fc
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigDir = "$env:USERPROFILE\.config\wezterm"

Write-Host ""
Write-Host "Setting up WezTerm configuration..." -ForegroundColor Blue
Write-Host ""

# Install WezTerm via winget if not present
if (-not (Get-Command wezterm -ErrorAction SilentlyContinue)) {
    Write-Host "WezTerm is not installed. Installing via winget..." -ForegroundColor Yellow

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install wez.wezterm --accept-package-agreements --accept-source-agreements
        Write-Host "WezTerm installed" -ForegroundColor Green
    } else {
        Write-Host "winget not found. Please install WezTerm manually from:" -ForegroundColor Red
        Write-Host "  https://wezfurlong.org/wezterm/install/windows.html"
        Write-Host ""
        Write-Host "Continuing with configuration setup..." -ForegroundColor Yellow
    }
} else {
    Write-Host "WezTerm is already installed" -ForegroundColor Green
}

# Create config directory
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

# Remove old config location if exists
$OldConfig = "$env:USERPROFILE\.wezterm.lua"
if (Test-Path $OldConfig) {
    if ((Get-Item $OldConfig).LinkType -eq "SymbolicLink") {
        Remove-Item $OldConfig -Force
        Write-Host "  Removed old symlink at ~/.wezterm.lua" -ForegroundColor Yellow
    } else {
        Move-Item $OldConfig "$OldConfig.backup" -Force
        Write-Host "  Backed up existing ~/.wezterm.lua" -ForegroundColor Yellow
    }
}

# Symlink configuration files
Write-Host "Creating symlinks to WezTerm configuration..."

$files = @(
    @{Source = ".wezterm.lua"; Dest = "wezterm.lua"},
    @{Source = "theme.lua"; Dest = "theme.lua"},
    @{Source = "platform.lua"; Dest = "platform.lua"},
    @{Source = "keys.lua"; Dest = "keys.lua"}
)

foreach ($file in $files) {
    $source = Join-Path $ScriptDir $file.Source
    $dest = Join-Path $ConfigDir $file.Dest

    if (Test-Path $source) {
        # Remove existing file/link if present
        if (Test-Path $dest) { Remove-Item $dest -Force }

        try {
            New-Item -ItemType SymbolicLink -Path $dest -Target $source -Force | Out-Null
            Write-Host "  Linked $($file.Dest)" -ForegroundColor Green
        } catch {
            # Symlinks require admin or Developer Mode - fall back to copy
            Copy-Item $source $dest -Force
            Write-Host "  Copied $($file.Dest) (symlink failed - enable Developer Mode for symlinks)" -ForegroundColor Yellow
        }
    }
}

# Copy icons directory
$IconsSource = Join-Path $ScriptDir "icons"
$IconsDest = Join-Path $ConfigDir "icons"
if (Test-Path $IconsSource) {
    if (Test-Path $IconsDest) { Remove-Item $IconsDest -Recurse -Force }
    Copy-Item -Recurse $IconsSource $IconsDest
    Write-Host "  Copied icons/" -ForegroundColor Green
}

# Update Start Menu shortcut icon
Write-Host ""
Write-Host "Installing custom WezTerm icon..."

$ShortcutPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\WezTerm.lnk",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\WezTerm.lnk"
)

$IconPath = Join-Path $IconsDest "wezterm.ico"
$IconSet = $false

foreach ($shortcut in $ShortcutPaths) {
    if (Test-Path $shortcut) {
        try {
            $shell = New-Object -ComObject WScript.Shell
            $lnk = $shell.CreateShortcut($shortcut)
            $lnk.IconLocation = $IconPath
            $lnk.Save()
            Write-Host "  Updated shortcut icon: $shortcut" -ForegroundColor Green
            $IconSet = $true
        } catch {
            Write-Host "  Could not update shortcut (may need admin rights): $shortcut" -ForegroundColor Yellow
        }
    }
}

if (-not $IconSet) {
    Write-Host "  No WezTerm shortcut found in Start Menu" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "WezTerm configuration installed to ~/.config/wezterm/" -ForegroundColor Green
Write-Host ""
Write-Host "Features enabled:"
Write-Host "  - Catppuccin Mocha theme"
Write-Host "  - FiraCode Nerd Font with ligatures"
Write-Host "  - Kitty graphics protocol for images"
Write-Host "  - WebGPU rendering"
Write-Host "  - Cross-platform support (macOS/Linux/Windows)"
Write-Host "  - Platform-aware keybindings"
Write-Host ""
Write-Host "Keybindings:"
Write-Host "  - Ctrl+T: New tab"
Write-Host "  - Ctrl+W: Close tab"
Write-Host "  - Ctrl+Shift+R: Rename tab"
Write-Host "  - Ctrl+Shift+|: Split horizontal"
Write-Host "  - Ctrl+Shift+_: Split vertical"
Write-Host "  - Ctrl+Shift+P: Shell picker"
Write-Host ""
