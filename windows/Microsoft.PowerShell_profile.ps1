# PowerShell Profile
# ==================
# Windows equivalent of .zshrc
# Location: ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# ============================================================================
# Environment Variables
# ============================================================================

# Set default editor (change to your preference)
$env:EDITOR = "code"

# Bat theme for syntax highlighting
$env:BAT_THEME = "Visual Studio Dark+"

# ============================================================================
# PATH Configuration
# ============================================================================

# Helper function to add paths without duplication
function Add-ToPath {
    param(
        [string]$PathToAdd
    )
    if (Test-Path $PathToAdd) {
        # Check if path is already in PATH (case-insensitive)
        $currentPaths = $env:PATH -split ';'
        $pathExists = $currentPaths | Where-Object { $_.TrimEnd('\') -eq $PathToAdd.TrimEnd('\') }

        if (-not $pathExists) {
            $env:PATH = "$PathToAdd;$env:PATH"
        }
    }
}

# Add user local bin to PATH
$LocalBin = Join-Path $env:USERPROFILE ".local\bin"
Add-ToPath $LocalBin

# Add cargo bin to PATH
$CargoBin = Join-Path $env:USERPROFILE ".cargo\bin"
Add-ToPath $CargoBin

# ============================================================================
# Tool Initialization
# ============================================================================

# Initialize Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Initialize zoxide (smart cd)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Initialize fnm (Fast Node Manager) if installed
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd | Out-String | Invoke-Expression
}

# ============================================================================
# PSReadLine Configuration (Enhanced Tab Completion)
# ============================================================================

# Import PSReadLine module
if (Get-Module -ListAvailable -Name PSReadLine) {
    try {
        Import-Module PSReadLine -ErrorAction Stop

        # Enable predictive IntelliSense
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView

        # Enhanced tab completion
        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

        # Bash-like completion
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

        # Useful shortcuts
        Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
        Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord

        # Better history
        Set-PSReadLineOption -HistorySearchCursorMovesToEnd
        Set-PSReadLineOption -MaximumHistoryCount 10000
    } catch {
        Write-Warning "Failed to configure PSReadLine: $_"
    }
}

# ============================================================================
# Source Aliases
# ============================================================================

# Load aliases from separate file
$AliasPath = Join-Path $PSScriptRoot "aliases.ps1"
if (Test-Path $AliasPath) {
    . $AliasPath
} else {
    # Try alternate location (if profile is in different directory)
    $DotfilesAliasPath = Join-Path $env:USERPROFILE ".dotfiles\windows\aliases.ps1"
    if (Test-Path $DotfilesAliasPath) {
        . $DotfilesAliasPath
    }
}

# ============================================================================
# Custom Functions
# ============================================================================

# Quick directory navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Quick access to common directories
function ~ { Set-Location $env:USERPROFILE }
function desktop { Set-Location (Join-Path $env:USERPROFILE "Desktop") }
function downloads { Set-Location (Join-Path $env:USERPROFILE "Downloads") }
function docs { Set-Location (Join-Path $env:USERPROFILE "Documents") }

# System information
function sysinfo {
    Get-ComputerInfo | Select-Object CsName, OsName, OsVersion, OsArchitecture
}

# Reload PowerShell profile
function Reload-Profile {
    & $PROFILE
    Write-Host "PowerShell profile reloaded" -ForegroundColor Green
}

# ============================================================================
# Welcome Message
# ============================================================================

# Uncomment to show welcome message on shell startup
# Write-Host "PowerShell $($PSVersionTable.PSVersion.ToString())" -ForegroundColor Cyan
# Write-Host "Type 'Get-Command' to see available commands" -ForegroundColor Gray
