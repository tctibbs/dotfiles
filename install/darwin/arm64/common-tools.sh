#!/usr/bin/env bash
set -euo pipefail

# Common tools installation for macOS via Homebrew

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "❌ Homebrew not found. Please install Homebrew first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "📦 Installing common tools via Homebrew..."

# List of tools to install
TOOLS=(
    "bat"       # Better cat
    "btop"      # Better top
    "dust"      # Disk usage analyzer
    "eza"       # Better ls
    "fd"        # Better find
    "fzf"       # Fuzzy finder
    "procs"     # Better ps
    "tldr"      # Simplified man pages
    "zoxide"    # Better cd
)

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        echo "✅ $tool is already installed"
    else
        echo "📦 Installing $tool..."
        brew install "$tool"
    fi
done

echo "✅ All common tools installed successfully!"