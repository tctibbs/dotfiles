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

# Install repomix via npm (requires Node.js)
if command -v repomix &>/dev/null; then
    echo "✅ repomix is already installed"
elif command -v npm &>/dev/null; then
    echo "📦 Installing repomix via npm..."
    npm install -g repomix
    echo "✅ repomix installed"
else
    echo "⚠️  npm not found - skipping repomix install"
fi

# Install Rust-based tools via cargo
if command -v cargo &>/dev/null; then
    # mcat - Markdown cat
    if command -v mcat &>/dev/null; then
        echo "✅ mcat is already installed"
    else
        echo "📦 Installing mcat via cargo..."
        cargo install mcat
        echo "✅ mcat installed"
    fi

    # treemd - Markdown directory trees
    if command -v treemd &>/dev/null; then
        echo "✅ treemd is already installed"
    else
        echo "📦 Installing treemd via cargo..."
        cargo install treemd
        echo "✅ treemd installed"
    fi

    # onefetch - Git repo info display
    if command -v onefetch &>/dev/null; then
        echo "✅ onefetch is already installed"
    else
        echo "📦 Installing onefetch via cargo..."
        cargo install onefetch
        echo "✅ onefetch installed"
    fi
else
    echo "⚠️  cargo not found - skipping mcat, treemd, and onefetch install"
fi
