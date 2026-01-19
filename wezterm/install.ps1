# WezTerm Installation Script for Windows
# ========================================
# Equivalent to install.sh for Unix systems
# Run in PowerShell: .\install.ps1

$ErrorActionPreference = "Stop"

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

# Install FiraCode Nerd Font if not present
Write-Host ""
Write-Host "Checking for FiraCode Nerd Font..."
$FontInstalled = $false
$FontsFolder = [Environment]::GetFolderPath("Fonts")

# Check if font is installed (look for any FiraCode NF file)
$FontFiles = Get-ChildItem -Path $FontsFolder -Filter "*FiraCode*NF*.ttf" -ErrorAction SilentlyContinue
if ($FontFiles.Count -gt 0) {
    Write-Host "FiraCode Nerd Font is already installed" -ForegroundColor Green
    $FontInstalled = $true
}

if (-not $FontInstalled) {
    Write-Host "FiraCode Nerd Font not found. Installing..." -ForegroundColor Yellow

    # Download and install directly from GitHub (most reliable)
    try {
        $TempDir = Join-Path $env:TEMP "FiraCodeNF"
        $ZipPath = Join-Path $TempDir "FiraCode.zip"
        New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

        Write-Host "  Downloading FiraCode Nerd Font from GitHub..." -ForegroundColor Cyan
        $FontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"
        Invoke-WebRequest -Uri $FontUrl -OutFile $ZipPath -UseBasicParsing

        Write-Host "  Extracting font files..." -ForegroundColor Cyan
        Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force

        Write-Host "  Installing fonts..." -ForegroundColor Cyan
        $FontFiles = Get-ChildItem -Path $TempDir -Filter "*.ttf" | Where-Object { $_.Name -notmatch "Windows Compatible" }

        # Install fonts (requires admin for system-wide, but user fonts work too)
        $FontsInstalled = 0
        $FONTS = 0x14
        $Shell = New-Object -ComObject Shell.Application
        $FontsFolder = $Shell.Namespace($FONTS)

        foreach ($FontFile in $FontFiles) {
            try {
                # Copy to user fonts directory (doesn't need admin)
                $UserFontsPath = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
                New-Item -ItemType Directory -Force -Path $UserFontsPath | Out-Null
                Copy-Item $FontFile.FullName -Destination $UserFontsPath -Force

                # Register font in registry
                $FontName = [System.IO.Path]::GetFileNameWithoutExtension($FontFile.Name)
                $RegPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
                New-ItemProperty -Path $RegPath -Name "$FontName (TrueType)" -Value $FontFile.Name -PropertyType String -Force | Out-Null

                $FontsInstalled++
            } catch {
                # Silent fail for individual fonts
            }
        }

        # Cleanup
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

        if ($FontsInstalled -gt 0) {
            Write-Host "FiraCode Nerd Font installed ($FontsInstalled files)" -ForegroundColor Green
            Write-Host "Note: Restart WezTerm to see the font" -ForegroundColor Yellow
            $FontInstalled = $true
        } else {
            throw "No fonts were installed"
        }

    } catch {
        Write-Host "  Automatic installation failed: $_" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Please install manually:" -ForegroundColor Yellow
        Write-Host "    1. Download: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip" -ForegroundColor Cyan
        Write-Host "    2. Extract and right-click .ttf files" -ForegroundColor Cyan
        Write-Host "    3. Select 'Install' or 'Install for all users'" -ForegroundColor Cyan
        Write-Host ""
    }
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
    @{Source = "keys.lua"; Dest = "keys.lua"},
    @{Source = "tabs.lua"; Dest = "tabs.lua"}
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

# Copy background image
$BackgroundSource = Join-Path $ScriptDir "background.jpg"
$BackgroundDest = Join-Path $ConfigDir "background.jpg"
if (Test-Path $BackgroundSource) {
    Copy-Item $BackgroundSource $BackgroundDest -Force
    Write-Host "  Copied background.jpg" -ForegroundColor Green
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
