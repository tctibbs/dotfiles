#!/usr/bin/env bash
set -euo pipefail

# Check if we can use sudo (passed from setup.sh or detect here)
CAN_SUDO="${CAN_SUDO:-false}"
if [[ "$CAN_SUDO" != "true" ]]; then
    # Try to detect sudo availability
    if command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
        CAN_SUDO="true"
    fi
fi

# Ensure ~/.local/bin exists
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# List of tools to install via apt (requires sudo)
APT_TOOLS=(
    "btop"
    "tldr"
    "bat"
    "zoxide"
    "tmux"
    "pgcli"
    "mycli"
    "litecli"
)

if [[ "$CAN_SUDO" == "true" ]]; then
    echo "Installing common Linux tools via apt..."

    # Update package list once
    echo "Updating package list..."
    sudo apt update

    # Install each tool
    for tool in "${APT_TOOLS[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo "$tool is already installed"
            continue
        fi

        echo "Installing $tool..."
        sudo apt install -y "$tool" || echo "Warning: Failed to install $tool"

        # Special handling for bat (Debian/Ubuntu naming quirk)
        if [[ "$tool" == "bat" ]]; then
            if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
                echo "Creating 'bat' symlink for 'batcat'"
                sudo ln -s "$(command -v batcat)" /usr/local/bin/bat 2>/dev/null || \
                    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
            fi
        fi
    done

    echo "APT tools installed!"
else
    echo "No sudo access - skipping apt packages"
    echo "The following tools require manual installation: ${APT_TOOLS[*]}"
fi

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

# Install Rust-based tools via cargo-binstall (downloads pre-built binaries)
if command -v cargo &>/dev/null; then
    # Install cargo-binstall if not present (downloads pre-built binary)
    if ! command -v cargo-binstall &>/dev/null; then
        echo "📦 Installing cargo-binstall..."
        curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
    fi

    # Tools to install via binstall
    RUST_TOOLS=(mcat treemd onefetch yazi)

    for tool in "${RUST_TOOLS[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo "✅ $tool is already installed"
        else
            echo "📦 Installing $tool via cargo-binstall..."
            cargo binstall -y "$tool"
            echo "✅ $tool installed"
        fi
    done

    # gobang needs version pin (not fully published to crates.io)
    if command -v gobang &>/dev/null; then
        echo "✅ gobang is already installed"
    else
        echo "📦 Installing gobang via cargo-binstall..."
        cargo binstall -y gobang@0.1.0-alpha.5
        echo "✅ gobang installed"
    fi
else
    echo "⚠️  cargo not found - skipping Rust tools (gobang, mcat, treemd, onefetch, yazi)"
fi
