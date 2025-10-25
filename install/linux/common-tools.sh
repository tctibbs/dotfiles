#!/usr/bin/env bash
set -euo pipefail

# List of tools to install via apt
COMMON_TOOLS=(
    "btop"
    "tldr"
    "bat"
    "zoxide"
    "tmux"
)

echo "📦 Installing common Linux tools via apt..."

# Update package list once
echo "🔄 Updating package list..."
sudo apt update

# Install each tool
for tool in "${COMMON_TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        echo "✅ $tool is already installed"
        continue
    fi
    
    echo "📦 Installing $tool..."
    sudo apt install -y "$tool"
    
    # Special handling for bat (Debian/Ubuntu naming quirk)
    if [[ "$tool" == "bat" ]]; then
        if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
            echo "🔧 Creating 'bat' symlink for 'batcat'"
            sudo ln -s "$(command -v batcat)" /usr/local/bin/bat
        fi
    fi
    
    echo "✅ $tool installed:"
    "$tool" --version
done

echo "🎉 All common Linux tools installed successfully!" 