# Git Configuration Installation Script for Windows
# =================================================
# Equivalent to install.sh for Unix systems
# Run in PowerShell: .\install.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$GitConfig = Join-Path $env:USERPROFILE ".gitconfig"
$GitConfigWork = Join-Path $env:USERPROFILE ".gitconfig-work"

Write-Host ""
Write-Host "Setting up Git configuration..." -ForegroundColor Blue
Write-Host ""

# Check if Git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed. Installing via winget..." -ForegroundColor Yellow

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install Git.Git --accept-package-agreements --accept-source-agreements
        Write-Host "Git installed" -ForegroundColor Green

        # Refresh PATH for current session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        Write-Host "winget not found. Please install Git manually from:" -ForegroundColor Red
        Write-Host "  https://git-scm.com/download/win" -ForegroundColor Red
        Write-Host ""
        Write-Host "Continuing with configuration setup..." -ForegroundColor Yellow
    }
} else {
    Write-Host "Git is already installed" -ForegroundColor Green
}

Write-Host ""

# ============================================================================
# Install .gitconfig
# ============================================================================

Write-Host "Installing Git configuration files..."

# Backup existing .gitconfig if not a symlink
if (Test-Path $GitConfig) {
    $item = Get-Item $GitConfig
    if ($item.LinkType -ne "SymbolicLink") {
        $backupPath = "$GitConfig.backup"
        Move-Item $GitConfig $backupPath -Force
        Write-Host "  Backed up existing .gitconfig" -ForegroundColor Yellow
    } else {
        # Remove existing symlink
        Remove-Item $GitConfig -Force
    }
}

# Create symlink or copy .gitconfig
$sourceGitConfig = Join-Path $ScriptDir ".gitconfig"
try {
    New-Item -ItemType SymbolicLink -Path $GitConfig -Target $sourceGitConfig -Force | Out-Null
    Write-Host "  Linked .gitconfig" -ForegroundColor Green
} catch {
    # Symlinks require Developer Mode or admin - fall back to copy
    Copy-Item $sourceGitConfig $GitConfig -Force
    Write-Host "  Copied .gitconfig (enable Developer Mode for symlinks)" -ForegroundColor Yellow
}

# ============================================================================
# Install .gitconfig-work
# ============================================================================

# Backup existing .gitconfig-work if not a symlink
if (Test-Path $GitConfigWork) {
    $item = Get-Item $GitConfigWork
    if ($item.LinkType -ne "SymbolicLink") {
        $backupPath = "$GitConfigWork.backup"
        Move-Item $GitConfigWork $backupPath -Force
        Write-Host "  Backed up existing .gitconfig-work" -ForegroundColor Yellow
    } else {
        # Remove existing symlink
        Remove-Item $GitConfigWork -Force
    }
}

# Create symlink or copy .gitconfig-work
$sourceGitConfigWork = Join-Path $ScriptDir ".gitconfig-work"
if (Test-Path $sourceGitConfigWork) {
    try {
        New-Item -ItemType SymbolicLink -Path $GitConfigWork -Target $sourceGitConfigWork -Force | Out-Null
        Write-Host "  Linked .gitconfig-work" -ForegroundColor Green
    } catch {
        # Fall back to copy
        Copy-Item $sourceGitConfigWork $GitConfigWork -Force
        Write-Host "  Copied .gitconfig-work (enable Developer Mode for symlinks)" -ForegroundColor Yellow
    }
}

# ============================================================================
# Display Information
# ============================================================================

Write-Host ""
Write-Host "Git configuration installed" -ForegroundColor Green
Write-Host ""
Write-Host "Aliases available:" -ForegroundColor Blue
Write-Host "  git amend    Amend last commit without editing message"
Write-Host "  git wip      Stage all + commit with 'WIP' message"
Write-Host "  git undo     Undo last commit, keep changes staged"
Write-Host ""
Write-Host "To use work-specific git config, add this to a repository's .git/config:" -ForegroundColor Yellow
Write-Host "  [include]" -ForegroundColor Cyan
Write-Host "    path = ~/.gitconfig-work" -ForegroundColor Cyan
Write-Host ""
