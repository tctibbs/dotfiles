# Starship Prompt Installation Script for Windows
# ===============================================
# Equivalent to install.sh for Unix systems
# Run in PowerShell: .\install.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigDir = Join-Path $env:USERPROFILE ".config"
$StarshipConfig = Join-Path $ConfigDir "starship.toml"

Write-Host ""
Write-Host "Setting up Starship prompt..." -ForegroundColor Blue
Write-Host ""

# Install Starship via winget if not present
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    Write-Host "Starship not found. Installing..." -ForegroundColor Yellow

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install Starship.Starship --accept-package-agreements --accept-source-agreements
        Write-Host "Starship installed" -ForegroundColor Green
    } else {
        Write-Host "winget not found. Please install Starship manually from:" -ForegroundColor Red
        Write-Host "  https://starship.rs/guide/#installation" -ForegroundColor Red
        Write-Host ""
        Write-Host "Or install via Scoop/Chocolatey:" -ForegroundColor Yellow
        Write-Host "  scoop install starship" -ForegroundColor Yellow
        Write-Host "  choco install starship" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Continuing with configuration setup..." -ForegroundColor Yellow
    }
} else {
    Write-Host "Starship is already installed" -ForegroundColor Green
}

# Create config directory if needed
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

# Backup existing starship.toml if it's not a symlink
if (Test-Path $StarshipConfig) {
    $item = Get-Item $StarshipConfig
    if ($item.LinkType -ne "SymbolicLink") {
        $backupPath = "$StarshipConfig.backup"
        Move-Item $StarshipConfig $backupPath -Force
        Write-Host "  Backed up existing starship.toml" -ForegroundColor Yellow
    } else {
        # Remove existing symlink
        Remove-Item $StarshipConfig -Force
    }
}

# Create symlink to configuration
Write-Host "Creating symlink to Starship configuration..."

$source = Join-Path $ScriptDir "starship.toml"
try {
    New-Item -ItemType SymbolicLink -Path $StarshipConfig -Target $source -Force | Out-Null
    Write-Host "  Linked starship.toml" -ForegroundColor Green
} catch {
    # Symlinks require Developer Mode or admin - fall back to copy
    Copy-Item $source $StarshipConfig -Force
    Write-Host "  Copied starship.toml (enable Developer Mode for symlinks)" -ForegroundColor Yellow
}

# Check if PowerShell profile exists and has starship init
$profilePath = $PROFILE.CurrentUserAllHosts
$profileDir = Split-Path -Parent $profilePath
$hasStarship = $false

if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath -Raw
    if ($profileContent -match "starship init powershell") {
        $hasStarship = $true
    }
}

if (-not $hasStarship) {
    Write-Host ""
    Write-Host "To enable Starship in PowerShell, add this to your profile:" -ForegroundColor Yellow
    Write-Host "  Invoke-Expression (&starship init powershell)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Your PowerShell profile is at:" -ForegroundColor Yellow
    Write-Host "  $profilePath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "The setup-powershell.ps1 script will handle this automatically." -ForegroundColor Blue
}

Write-Host ""
Write-Host "Starship configuration installed" -ForegroundColor Green
Write-Host ""
Write-Host "Features enabled:"
Write-Host "  - Nord color palette"
Write-Host "  - Two-line prompt with git info"
Write-Host "  - Language version indicators"
Write-Host "  - AWS and Docker context"
Write-Host "  - Command duration tracking"
Write-Host ""
