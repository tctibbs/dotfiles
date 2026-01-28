# Windows Terminal Configuration Installer
# Backs up existing settings and installs dotfiles configuration

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceSettings = Join-Path $ScriptDir "settings.json"
$TerminalLocalState = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$TerminalPreviewLocalState = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState"

function Write-Status {
    param([string]$Message, [string]$Type = "Info")
    $colors = @{
        "Info" = "Cyan"
        "Success" = "Green"
        "Warning" = "Yellow"
        "Error" = "Red"
    }
    Write-Host "[$Type] $Message" -ForegroundColor $colors[$Type]
}

function Backup-Settings {
    param([string]$SettingsPath)

    if (Test-Path $SettingsPath) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = "$SettingsPath.backup_$timestamp"
        Copy-Item -Path $SettingsPath -Destination $backupPath -Force
        Write-Status "Backed up existing settings to: $backupPath" "Success"
        return $true
    }
    return $false
}

function Install-Settings {
    param(
        [string]$SourcePath,
        [string]$TargetDir,
        [string]$Name
    )

    if (-not (Test-Path $TargetDir)) {
        Write-Status "$Name not found at $TargetDir" "Warning"
        return $false
    }

    $targetPath = Join-Path $TargetDir "settings.json"

    # Backup existing
    Backup-Settings -SettingsPath $targetPath | Out-Null

    # Copy new settings
    if ($PSCmdlet.ShouldProcess($targetPath, "Install settings")) {
        Copy-Item -Path $SourcePath -Destination $targetPath -Force
        Write-Status "Installed settings to: $targetPath" "Success"
    }
    return $true
}

# Main installation
Write-Host ""
Write-Host "Windows Terminal Configuration Installer" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# Check source file exists
if (-not (Test-Path $SourceSettings)) {
    Write-Status "Source settings.json not found at: $SourceSettings" "Error"
    exit 1
}

$installed = $false

# Install for Windows Terminal (stable)
if (Test-Path $TerminalLocalState) {
    Write-Status "Found Windows Terminal (stable)" "Info"
    if (Install-Settings -SourcePath $SourceSettings -TargetDir $TerminalLocalState -Name "Windows Terminal") {
        $installed = $true
    }
}

# Install for Windows Terminal Preview
if (Test-Path $TerminalPreviewLocalState) {
    Write-Status "Found Windows Terminal Preview" "Info"
    if (Install-Settings -SourcePath $SourceSettings -TargetDir $TerminalPreviewLocalState -Name "Windows Terminal Preview") {
        $installed = $true
    }
}

if (-not $installed) {
    Write-Status "No Windows Terminal installation found." "Warning"
    Write-Status "Please install Windows Terminal from the Microsoft Store or winget:" "Info"
    Write-Host "  winget install Microsoft.WindowsTerminal" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Status "Installation complete!" "Success"
Write-Host ""
Write-Host "Configuration includes:" -ForegroundColor White
Write-Host "  - Catppuccin Mocha color scheme"
Write-Host "  - FiraCode Nerd Font (13pt with ligatures)"
Write-Host "  - Acrylic blur effect (85% opacity)"
Write-Host "  - Visual bell (no audio)"
Write-Host "  - 10,000 line scrollback"
Write-Host "  - Bar cursor"
Write-Host ""
Write-Host "Keybindings:" -ForegroundColor White
Write-Host "  Ctrl+T           - New tab"
Write-Host "  Ctrl+W           - Close tab"
Write-Host "  Ctrl+Shift+\     - Vertical split"
Write-Host "  Ctrl+Shift+-     - Horizontal split"
Write-Host "  Ctrl+Shift+Arrow - Navigate panes"
Write-Host "  Ctrl+Shift+W     - Close pane"
Write-Host "  Alt+1-5          - Switch tabs"
Write-Host "  Ctrl+Enter       - Toggle fullscreen"
Write-Host ""
Write-Host "Note: Ensure FiraCode Nerd Font is installed:" -ForegroundColor Yellow
Write-Host "  winget install Nerd-Fonts.FiraCode" -ForegroundColor White
Write-Host ""
