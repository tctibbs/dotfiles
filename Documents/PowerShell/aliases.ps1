# PowerShell Aliases
# ==================
# Windows equivalent of aliash.zsh
# Sourced by Microsoft.PowerShell_profile.ps1

# ============================================================================
# Modern CLI Tool Aliases
# ============================================================================

# Colorize grep output (if using GNU grep)
if (Get-Command grep -ErrorAction SilentlyContinue) {
    function grep { command grep --color=auto @args }
    function egrep { command egrep --color=auto @args }
    function fgrep { command fgrep --color=auto @args }
}

# ============================================================================
# eza - Modern replacement for ls
# ============================================================================

if (Get-Command eza -ErrorAction SilentlyContinue) {
    # Basic listings
    function ls { eza --icons --color=always --group-directories-first @args }
    function ll { eza -lgh --icons --color=always --group-directories-first @args }
    function la { eza -la --icons --color=always --group-directories-first @args }

    # Tree views
    function lt { eza -T --icons --color=always --group-directories-first @args }
    function llt { eza -lTgh --icons --color=always --group-directories-first @args }

    # Specialized views
    function ld { eza -D --icons --color=always --group-directories-first @args }
    function lm { eza -ls=modified -la --icons --color=always --group-directories-first @args }
} else {
    Write-Warning "eza not found - using default ls commands"
}

# ============================================================================
# bat - Modern replacement for cat
# ============================================================================

if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat { bat @args }
} else {
    Write-Warning "bat not found - using default cat"
}

# ============================================================================
# dust - Modern replacement for du
# ============================================================================

if (Get-Command dust -ErrorAction SilentlyContinue) {
    function du { dust @args }
} else {
    Write-Warning "dust not found - using default du"
}

# ============================================================================
# procs - Modern replacement for ps
# ============================================================================

# Note: PowerShell has a built-in 'ps' alias for Get-Process
# We create a different alias to avoid conflicts
if (Get-Command procs -ErrorAction SilentlyContinue) {
    function proc { procs @args }
    # Uncomment to override built-in ps (not recommended)
    # Remove-Item Alias:ps -Force
    # function ps { procs @args }
} else {
    Write-Warning "procs not found - using default Get-Process"
}

# ============================================================================
# fd - Modern replacement for find
# ============================================================================

if (Get-Command fd -ErrorAction SilentlyContinue) {
    # fd is already a standalone command, but we can add helpful aliases
    function fda { fd --hidden --no-ignore @args }  # Search hidden files
} else {
    Write-Warning "fd not found"
}

# ============================================================================
# Claude Code Aliases
# ============================================================================

if (Get-Command claude -ErrorAction SilentlyContinue) {
    # cc - Claude Code without permissions
    function cc { claude --dangerously-skip-permissions @args }

    # ccc - Claude Code with continue flag
    function ccc { claude --dangerously-skip-permissions -c @args }
}

# ============================================================================
# Gemini CLI Aliases
# ============================================================================

if (Get-Command gemini -ErrorAction SilentlyContinue) {
    # gf - Gemini Flash model
    function gf { gemini --model gemini-2.5-flash @args }
}

# ============================================================================
# yazi - Terminal File Manager with cd on exit
# ============================================================================

if (Get-Command yazi -ErrorAction SilentlyContinue) {
    function y {
        $tmp = [System.IO.Path]::GetTempFileName()
        yazi @args --cwd-file="$tmp"

        # Read the final directory from the temp file
        $cwd = Get-Content -Path $tmp -ErrorAction SilentlyContinue
        if ($cwd -and $cwd -ne $PWD.Path) {
            Set-Location -Path $cwd
        }

        # Clean up temp file
        Remove-Item -Path $tmp -ErrorAction SilentlyContinue
    }
}

# ============================================================================
# Database Tools
# ============================================================================

# gobang - Database TUI client config editor
if (Get-Command gobang -ErrorAction SilentlyContinue) {
    function dbconfig {
        $configPath = Join-Path $env:USERPROFILE ".config\gobang\config.toml"
        & $env:EDITOR $configPath
    }
}

# ============================================================================
# Git Aliases (if not already set in gitconfig)
# ============================================================================

function gst { git status @args }
function gco { git checkout @args }
function gcm { git commit @args }
function gpl { git pull @args }
function gps { git push @args }
function glog { git log --oneline --graph --decorate @args }

# ============================================================================
# Docker Aliases (if Docker is installed)
# ============================================================================

if (Get-Command docker -ErrorAction SilentlyContinue) {
    function dps { docker ps @args }
    function dpsa { docker ps -a @args }
    function di { docker images @args }
    function dex { docker exec -it @args }
    function dlog { docker logs @args }
    function dstop { docker stop @args }
    function drm { docker rm @args }
    function drmi { docker rmi @args }
}

# ============================================================================
# System Utilities
# ============================================================================

# Quick file size
function filesize {
    param([string]$Path = ".")
    Get-ChildItem -Path $Path -Recurse -File |
        Measure-Object -Property Length -Sum |
        Select-Object @{Name="Size(MB)";Expression={[math]::Round($_.Sum/1MB, 2)}}
}

# Find large files
function Find-LargeFiles {
    param(
        [string]$Path = ".",
        [int]$TopN = 10
    )
    Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending |
        Select-Object -First $TopN |
        Format-Table Name, @{Label="Size(MB)";Expression={[math]::Round($_.Length/1MB, 2)}} -AutoSize
}

# ============================================================================
# Networking
# ============================================================================

# Quick ping
function ping-google { ping 8.8.8.8 }

# Check port
function Test-Port {
    param(
        [string]$Host,
        [int]$Port
    )
    Test-NetConnection -ComputerName $Host -Port $Port
}

# ============================================================================
# Development Shortcuts
# ============================================================================

# Python venv activation helper
function venv {
    if (Test-Path ".\.venv\Scripts\Activate.ps1") {
        & .\.venv\Scripts\Activate.ps1
    } elseif (Test-Path ".\venv\Scripts\Activate.ps1") {
        & .\venv\Scripts\Activate.ps1
    } else {
        Write-Host "No virtual environment found" -ForegroundColor Yellow
    }
}

# Quick HTTP server (Python)
function http-server {
    param([int]$Port = 8000)
    if (Get-Command python -ErrorAction SilentlyContinue) {
        python -m http.server $Port
    } else {
        Write-Host "Python not found" -ForegroundColor Red
    }
}

# ============================================================================
# Lazygit / Lazydocker
# ============================================================================

if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Set-Alias -Name lg -Value lazygit
}

if (Get-Command lazydocker -ErrorAction SilentlyContinue) {
    Set-Alias -Name lzd -Value lazydocker
}
