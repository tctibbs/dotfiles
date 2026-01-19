#!/usr/bin/env pwsh
# Windows Dotfiles Setup Script
# =============================
# Equivalent to setup.sh for Unix systems
# Run in PowerShell: .\setup.ps1

$ErrorActionPreference = "Stop"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Colors for output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

Write-Host ""
Write-ColorOutput "========================================" "Blue"
Write-ColorOutput "   Windows Dotfiles Setup" "Blue"
Write-ColorOutput "========================================" "Blue"
Write-Host ""

# Check PowerShell version
Write-ColorOutput "Checking prerequisites..." "Blue"
$PSVersion = $PSVersionTable.PSVersion
if ($PSVersion.Major -lt 5) {
    Write-ColorOutput "ERROR: PowerShell 5.0 or higher is required (current: $PSVersion)" "Red"
    Write-ColorOutput "Please upgrade PowerShell: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows" "Yellow"
    exit 1
}
Write-ColorOutput "  PowerShell $PSVersion" "Green"

# Check execution policy
$Policy = Get-ExecutionPolicy -Scope CurrentUser
if ($Policy -eq 'Restricted' -or $Policy -eq 'Undefined') {
    Write-ColorOutput "  Setting execution policy to RemoteSigned..." "Yellow"
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-ColorOutput "  Execution policy updated" "Green"
    } catch {
        Write-ColorOutput "  WARNING: Could not set execution policy. Scripts may be blocked." "Yellow"
    }
}

# Check for winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-ColorOutput "  WARNING: winget not found. Many tools require winget." "Yellow"
    Write-ColorOutput "  Install from: https://aka.ms/getwinget" "Yellow"
} else {
    Write-ColorOutput "  winget available" "Green"
}

# Check for Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-ColorOutput "  WARNING: Git not found. Installing via winget..." "Yellow"
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install Git.Git --accept-package-agreements --accept-source-agreements
        Write-ColorOutput "  Git installed" "Green"
    } else {
        Write-ColorOutput "  ERROR: Cannot install Git without winget" "Red"
        exit 1
    }
} else {
    Write-ColorOutput "  Git available" "Green"
}

Write-Host ""

# Run Starship setup
Write-Host ""
Write-ColorOutput "========================================" "Blue"
Write-ColorOutput "   Setting up Starship prompt..." "Blue"
Write-ColorOutput "========================================" "Blue"
Write-Host ""
$StarshipScript = Join-Path $ScriptDir "starship" "install.ps1"
if (Test-Path $StarshipScript) {
    & $StarshipScript
} else {
    Write-ColorOutput "Warning: starship/install.ps1 not found. Skipping starship setup." "Yellow"
}

# Run WezTerm setup
Write-Host ""
Write-ColorOutput "========================================" "Blue"
Write-ColorOutput "   Setting up WezTerm..." "Blue"
Write-ColorOutput "========================================" "Blue"
Write-Host ""
$WeztermScript = Join-Path $ScriptDir "wezterm" "install.ps1"
if (Test-Path $WeztermScript) {
    & $WeztermScript
} else {
    Write-ColorOutput "Warning: wezterm/install.ps1 not found. Skipping wezterm setup." "Yellow"
}

# Run Git setup
Write-Host ""
Write-ColorOutput "========================================" "Blue"
Write-ColorOutput "   Setting up Git configuration..." "Blue"
Write-ColorOutput "========================================" "Blue"
Write-Host ""
$GitScript = Join-Path $ScriptDir "git" "install.ps1"
if (Test-Path $GitScript) {
    & $GitScript
} else {
    Write-ColorOutput "Note: git/install.ps1 not found. Skipping git configuration." "Yellow"
}

# Run common tools installation
Write-Host ""
Write-ColorOutput "========================================" "Blue"
Write-ColorOutput "   Installing common CLI tools..." "Blue"
Write-ColorOutput "========================================" "Blue"
Write-Host ""
$ToolsScript = Join-Path $ScriptDir "install" "windows" "common-tools.ps1"
if (Test-Path $ToolsScript) {
    & $ToolsScript
} else {
    Write-ColorOutput "Warning: install/windows/common-tools.ps1 not found. Skipping tools installation." "Yellow"
}

# Run PowerShell profile setup
Write-Host ""
Write-ColorOutput "========================================" "Blue"
Write-ColorOutput "   Setting up PowerShell profile..." "Blue"
Write-ColorOutput "========================================" "Blue"
Write-Host ""
$ProfileScript = Join-Path $ScriptDir "install" "windows" "setup-powershell.ps1"
if (Test-Path $ProfileScript) {
    & $ProfileScript
} else {
    Write-ColorOutput "Warning: install/windows/setup-powershell.ps1 not found. Skipping PowerShell profile setup." "Yellow"
}

# Summary
Write-Host ""
Write-ColorOutput "========================================" "Green"
Write-ColorOutput "   Setup Complete!" "Green"
Write-ColorOutput "========================================" "Green"
Write-Host ""
Write-ColorOutput "Next steps:" "Blue"
Write-Host "  1. Restart PowerShell to load new configuration"
Write-Host "  2. Launch WezTerm to see your new terminal setup"
Write-Host "  3. Run 'starship --version' to verify Starship is installed"
Write-Host ""
Write-ColorOutput "To enable symlinks (recommended):" "Yellow"
Write-Host "  - Enable Developer Mode in Windows Settings"
Write-Host "  - Or run PowerShell as Administrator"
Write-Host ""
Write-ColorOutput "If you encounter any issues, check the individual install scripts in:" "Blue"
Write-Host "  - starship/install.ps1"
Write-Host "  - wezterm/install.ps1"
Write-Host "  - install/windows/common-tools.ps1"
Write-Host ""
