#!/usr/bin/env pwsh
# PowerShell Profile Setup Script
# ================================
# Links PowerShell profile and aliases to correct locations

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DotfilesRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)

Write-Host ""
Write-Host "Setting up PowerShell profile..." -ForegroundColor Blue
Write-Host ""

# Determine PowerShell profile location
$ProfilePath = $PROFILE.CurrentUserAllHosts
$ProfileDir = Split-Path -Parent $ProfilePath

Write-Host "Profile location: $ProfilePath" -ForegroundColor Cyan

# Create PowerShell profile directory if it doesn't exist
if (-not (Test-Path $ProfileDir)) {
    Write-Host "  Creating PowerShell profile directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null
    Write-Host "  Created $ProfileDir" -ForegroundColor Green
}

# Source files in dotfiles
$SourceProfile = Join-Path $DotfilesRoot "windows" "Microsoft.PowerShell_profile.ps1"
$SourceAliases = Join-Path $DotfilesRoot "windows" "aliases.ps1"

# Check if source files exist
if (-not (Test-Path $SourceProfile)) {
    Write-Host "ERROR: Source profile not found at $SourceProfile" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $SourceAliases)) {
    Write-Host "WARNING: Source aliases not found at $SourceAliases" -ForegroundColor Yellow
}

# ============================================================================
# Install PowerShell Profile
# ============================================================================

Write-Host "Installing PowerShell profile..."

# Backup existing profile if it's not a symlink
if (Test-Path $ProfilePath) {
    $item = Get-Item $ProfilePath
    if ($item.LinkType -ne "SymbolicLink") {
        $backupPath = "$ProfilePath.backup"
        Move-Item $ProfilePath $backupPath -Force
        Write-Host "  Backed up existing profile to $backupPath" -ForegroundColor Yellow
    } else {
        # Remove existing symlink
        Remove-Item $ProfilePath -Force
        Write-Host "  Removed existing symlink" -ForegroundColor Yellow
    }
}

# Create symlink or copy profile
try {
    New-Item -ItemType SymbolicLink -Path $ProfilePath -Target $SourceProfile -Force | Out-Null
    Write-Host "  Linked profile" -ForegroundColor Green
} catch {
    # Symlinks require Developer Mode or admin - fall back to copy
    Copy-Item $SourceProfile $ProfilePath -Force
    Write-Host "  Copied profile (enable Developer Mode for symlinks)" -ForegroundColor Yellow
}

# ============================================================================
# Install Aliases File
# ============================================================================

if (Test-Path $SourceAliases) {
    Write-Host "Installing PowerShell aliases..."

    $AliasesPath = Join-Path $ProfileDir "aliases.ps1"

    # Backup existing aliases if not a symlink
    if (Test-Path $AliasesPath) {
        $item = Get-Item $AliasesPath
        if ($item.LinkType -ne "SymbolicLink") {
            $backupPath = "$AliasesPath.backup"
            Move-Item $AliasesPath $backupPath -Force
            Write-Host "  Backed up existing aliases to $backupPath" -ForegroundColor Yellow
        } else {
            # Remove existing symlink
            Remove-Item $AliasesPath -Force
        }
    }

    # Create symlink or copy aliases
    try {
        New-Item -ItemType SymbolicLink -Path $AliasesPath -Target $SourceAliases -Force | Out-Null
        Write-Host "  Linked aliases" -ForegroundColor Green
    } catch {
        # Fall back to copy
        Copy-Item $SourceAliases $AliasesPath -Force
        Write-Host "  Copied aliases (enable Developer Mode for symlinks)" -ForegroundColor Yellow
    }
}

# ============================================================================
# Verify Profile Content
# ============================================================================

Write-Host ""
Write-Host "Verifying profile setup..."

# Check if Starship is initialized in profile
$ProfileContent = Get-Content $ProfilePath -Raw
$HasStarship = $ProfileContent -match "starship init powershell"

if (-not $HasStarship) {
    Write-Host "  WARNING: Starship initialization not found in profile" -ForegroundColor Yellow
    Write-Host "  The profile template should include Starship init" -ForegroundColor Yellow
}

# ============================================================================
# Success Message
# ============================================================================

Write-Host ""
Write-Host "PowerShell profile installed successfully" -ForegroundColor Green
Write-Host ""
Write-Host "Features enabled:" -ForegroundColor Cyan
Write-Host "  - Starship prompt initialization"
Write-Host "  - Zoxide (smart cd) integration"
Write-Host "  - Modern CLI tool aliases (eza, bat, dust, etc.)"
Write-Host "  - Enhanced PSReadLine tab completion"
Write-Host "  - Custom helper functions"
Write-Host ""
Write-Host "Profile location: $ProfilePath" -ForegroundColor Cyan
Write-Host ""
Write-Host "To apply changes, restart PowerShell or run:" -ForegroundColor Yellow
Write-Host "  . `$PROFILE" -ForegroundColor Cyan
Write-Host ""

# Offer to reload profile
$Reload = Read-Host "Reload profile now? (y/n)"
if ($Reload -eq 'y' -or $Reload -eq 'Y') {
    try {
        . $ProfilePath
        Write-Host ""
        Write-Host "Profile reloaded successfully" -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Host "Error reloading profile: $_" -ForegroundColor Red
        Write-Host "Please restart PowerShell to load the new profile" -ForegroundColor Yellow
    }
}

Write-Host ""
