#!/usr/bin/env pwsh
# Common CLI Tools Installation Script for Windows
# ================================================
# Installs modern CLI tools using winget and cargo
# Equivalent to install/linux/common-tools.sh

$ErrorActionPreference = "Continue"  # Continue on errors for individual tools

Write-Host ""
Write-Host "Installing common CLI tools..." -ForegroundColor Blue
Write-Host ""

# Track installation results
$Installed = @()
$Skipped = @()
$Failed = @()

# Define tools by installation method
$WingetTools = @{
    "bat" = "sharkdp.bat"
    "fd" = "sharkdp.fd"
    "fzf" = "junegunn.fzf"
    "zoxide" = "ajeetdsouza.zoxide"
    "tldr" = "tldr-pages.tlrc"
    "eza" = "eza-community.eza"
}

$CargoTools = @(
    "dust",
    "procs",
    "yazi-fm",
    "mcat",
    "treemd",
    "onefetch"
)

# Special cargo tools that need specific handling
$SpecialCargoTools = @{
    "gobang" = "--version 0.1.0-alpha.5"
}

# Helper function to check if a command exists
function Test-Command {
    param([string]$Command)
    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Install winget tools
Write-Host "Installing tools via winget..." -ForegroundColor Cyan
Write-Host ""

if (Test-Command winget) {
    foreach ($tool in $WingetTools.Keys) {
        $package = $WingetTools[$tool]

        if (Test-Command $tool) {
            Write-Host "  $tool is already installed" -ForegroundColor Green
            $Skipped += $tool
            continue
        }

        Write-Host "  Installing $tool..." -ForegroundColor Yellow
        try {
            $result = winget install $package --accept-package-agreements --accept-source-agreements 2>&1
            if ($LASTEXITCODE -eq 0 -or (Test-Command $tool)) {
                Write-Host "  $tool installed" -ForegroundColor Green
                $Installed += $tool
            } else {
                Write-Host "  $tool installation may have failed" -ForegroundColor Yellow
                $Failed += $tool
            }
        } catch {
            Write-Host "  Failed to install $tool : $_" -ForegroundColor Red
            $Failed += $tool
        }
    }
} else {
    Write-Host "  winget not found - skipping winget tools" -ForegroundColor Yellow
    Write-Host "  Install winget from: https://aka.ms/getwinget" -ForegroundColor Yellow
    $Failed += $WingetTools.Keys
}

Write-Host ""

# Install Rust and cargo if needed for cargo tools
Write-Host "Installing Rust tools via cargo..." -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Command cargo)) {
    Write-Host "  Cargo not found. Installing Rust via rustup..." -ForegroundColor Yellow

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        try {
            winget install Rustlang.Rustup --accept-package-agreements --accept-source-agreements

            # Add cargo to PATH for current session
            $CargoPath = Join-Path $env:USERPROFILE ".cargo\bin"
            if (Test-Path $CargoPath) {
                $env:PATH = "$CargoPath;$env:PATH"
            }

            # Refresh environment
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            Write-Host "  Rustup installed" -ForegroundColor Green
            Write-Host "  You may need to restart PowerShell for cargo to be available" -ForegroundColor Yellow
        } catch {
            Write-Host "  Failed to install rustup" -ForegroundColor Red
            Write-Host "  Please install manually from: https://rustup.rs/" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  Please install Rust from: https://rustup.rs/" -ForegroundColor Yellow
    }
}

# Check for MSVC linker (required for cargo compilation)
$HasMSVC = $false
if (Test-Command cargo) {
    # Test if link.exe is available (MSVC linker)
    if (Get-Command link.exe -ErrorAction SilentlyContinue) {
        $HasMSVC = $true
    } else {
        Write-Host ""
        Write-Host "  WARNING: MSVC linker (link.exe) not found" -ForegroundColor Yellow
        Write-Host "  Cargo tools require Visual Studio C++ Build Tools to compile" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Install via winget:" -ForegroundColor Cyan
        Write-Host "    winget install Microsoft.VisualStudio.2022.BuildTools" -ForegroundColor Cyan
        Write-Host "    - Select 'Desktop development with C++' workload" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Or download manually:" -ForegroundColor Cyan
        Write-Host "    https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Skipping cargo tools that require compilation..." -ForegroundColor Yellow
        Write-Host "  Using cargo-binstall for pre-built binaries where available" -ForegroundColor Yellow
        Write-Host ""
    }
}

# Install cargo-binstall for faster binary installations (also requires MSVC)
if (Test-Command cargo) {
    if (-not (Test-Command cargo-binstall)) {
        if ($HasMSVC) {
            Write-Host "  Installing cargo-binstall for faster binary downloads..." -ForegroundColor Yellow
            try {
                cargo install cargo-binstall

                # Refresh PATH to pick up newly installed binary
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

                # Verify installation
                if (Test-Command cargo-binstall) {
                    Write-Host "  cargo-binstall installed" -ForegroundColor Green
                } else {
                    Write-Host "  cargo-binstall installed but not in PATH - restart PowerShell" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "  Failed to install cargo-binstall" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  Skipping cargo-binstall (requires MSVC to compile)" -ForegroundColor Yellow
        }
    }

    # Install regular cargo tools
    foreach ($tool in $CargoTools) {
        $toolName = $tool -replace "-fm$", ""  # yazi-fm -> yazi for command check

        if (Test-Command $toolName) {
            Write-Host "  $toolName is already installed" -ForegroundColor Green
            $Skipped += $toolName
            continue
        }

        Write-Host "  Installing $toolName via cargo..." -ForegroundColor Yellow
        try {
            if (Test-Command cargo-binstall) {
                cargo-binstall -y $tool
            } elseif ($HasMSVC) {
                cargo install $tool
            } else {
                Write-Host "  Skipping $toolName (requires MSVC to compile)" -ForegroundColor Yellow
                $Failed += $toolName
                continue
            }
            if (Test-Command $toolName) {
                Write-Host "  $toolName installed" -ForegroundColor Green
                $Installed += $toolName
            } else {
                Write-Host "  $toolName installation may have failed" -ForegroundColor Yellow
                $Failed += $toolName
            }
        } catch {
            Write-Host "  Failed to install $toolName : $_" -ForegroundColor Red
            $Failed += $toolName
        }
    }

    # Install special cargo tools
    foreach ($tool in $SpecialCargoTools.Keys) {
        if (Test-Command $tool) {
            Write-Host "  $tool is already installed" -ForegroundColor Green
            $Skipped += $tool
            continue
        }

        $toolArgs = $SpecialCargoTools[$tool]
        $argsList = $toolArgs.Split(' ')
        Write-Host "  Installing $tool via cargo..." -ForegroundColor Yellow
        try {
            if (Test-Command cargo-binstall) {
                cargo-binstall -y $tool $argsList
            } elseif ($HasMSVC) {
                cargo install $tool $argsList
            } else {
                Write-Host "  Skipping $tool (requires MSVC to compile)" -ForegroundColor Yellow
                $Failed += $tool
                continue
            }
            if (Test-Command $tool) {
                Write-Host "  $tool installed" -ForegroundColor Green
                $Installed += $tool
            } else {
                Write-Host "  $tool installation may have failed" -ForegroundColor Yellow
                $Failed += $tool
            }
        } catch {
            Write-Host "  Failed to install $tool : $_" -ForegroundColor Red
            $Failed += $tool
        }
    }
} else {
    Write-Host "  Cargo not available - skipping Rust tools" -ForegroundColor Yellow
    $Failed += $CargoTools
    $Failed += $SpecialCargoTools.Keys
}

# Summary
Write-Host ""
Write-Host "======================================" -ForegroundColor Blue
Write-Host "Installation Summary" -ForegroundColor Blue
Write-Host "======================================" -ForegroundColor Blue
Write-Host ""

if ($Installed.Count -gt 0) {
    Write-Host "Installed ($($Installed.Count)):" -ForegroundColor Green
    $Installed | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
    Write-Host ""
}

if ($Skipped.Count -gt 0) {
    Write-Host "Already installed ($($Skipped.Count)):" -ForegroundColor Cyan
    $Skipped | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
    Write-Host ""
}

if ($Failed.Count -gt 0) {
    Write-Host "Failed or skipped ($($Failed.Count)):" -ForegroundColor Yellow
    $Failed | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    Write-Host ""
    Write-Host "Note: Some tools may require a PowerShell restart or manual installation" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "All common CLI tools processed" -ForegroundColor Green
Write-Host ""
