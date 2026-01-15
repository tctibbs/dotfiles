#!/bin/bash
# Setup file for docker dev containers extension for VS Code

SUDO=""
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect OS and use the appropriate package manager
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    $SUDO apt update
    $SUDO apt install -y zsh stow
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Check if Homebrew is installed, install if missing
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add brew to PATH for Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi

    # Install all packages via Brewfile
    if [[ -f "$SCRIPT_DIR/homebrew/install.sh" ]]; then
        bash "$SCRIPT_DIR/homebrew/install.sh"
    else
        # Fallback: install essentials
        brew install zsh stow
    fi
else
    echo "Unsupported OS. This script only works on Linux and macOS."
    exit 1
fi

# Use stow to link zsh configuration
echo "Linking zsh configuration with stow..."
stow -v -R --target="$HOME" zsh

# Use stow to link tmux configuration
echo "Linking tmux configuration with stow..."
stow -v -R --target="$HOME" tmux

# Note: wezterm configuration is linked by wezterm/install.sh to ~/.config/wezterm/

# Run git setup
echo ""
echo "Setting up git configuration..."
if [[ -f "$SCRIPT_DIR/git/install.sh" ]]; then
    bash "$SCRIPT_DIR/git/install.sh"
else
    echo "Warning: git install script not found. Skipping git setup."
fi
# Create ~/.config/zsh directory and link additional config files
echo "Creating ~/.config/zsh directory and linking additional config files..."
mkdir -p "$HOME/.config/zsh"
ln -sf "$SCRIPT_DIR/zsh/aliash.zsh" "$HOME/.config/zsh/aliash.zsh"

# Verify the symlink for .zshrc
if [ -L "$HOME/.zshrc" ] && [ -f "$HOME/.zshrc" ]; then
    echo ".zshrc linked successfully."
else
    echo "Error: .zshrc was not linked. Check your stow setup or folder structure."
fi

if [ -L "$HOME/.tmux.conf" ] && [ -f "$HOME/.tmux.conf" ]; then
    echo ".tmux.conf linked successfully."
else
    echo "Warning: .tmux.conf was not linked. Check your stow setup or folder structure."
fi

# Install Tmux Plugin Manager (TPM) and plugins
if command -v tmux &>/dev/null; then
    TMUX_PLUGINS_DIR="$HOME/.tmux/plugins"
    mkdir -p "$TMUX_PLUGINS_DIR"

    # Install TPM itself
    TPM_DIR="$TMUX_PLUGINS_DIR/tpm"
    if [ ! -d "$TPM_DIR" ]; then
        echo "📦 Installing Tmux Plugin Manager (TPM)..."
        git clone --quiet https://github.com/tmux-plugins/tpm "$TPM_DIR"
        echo "✅ TPM installed"
    else
        echo "✅ TPM is already installed"
    fi

    # Install plugins directly (same plugins as configured in .tmux.conf)
    echo "📦 Installing tmux plugins..."

    declare -A PLUGINS=(
        ["tmux-sensible"]="https://github.com/tmux-plugins/tmux-sensible"
        ["tmux-resurrect"]="https://github.com/tmux-plugins/tmux-resurrect"
        ["tmux-continuum"]="https://github.com/tmux-plugins/tmux-continuum"
        ["tmux-yank"]="https://github.com/tmux-plugins/tmux-yank"
        ["tmux-fzf"]="https://github.com/sainnhe/tmux-fzf"
        ["tmux-battery"]="https://github.com/tmux-plugins/tmux-battery"
        ["tmux-cpu"]="https://github.com/tmux-plugins/tmux-cpu"
        ["tmux-prefix-highlight"]="https://github.com/tmux-plugins/tmux-prefix-highlight"
        ["tmux-open"]="https://github.com/tmux-plugins/tmux-open"
    )

    for plugin in "${!PLUGINS[@]}"; do
        PLUGIN_DIR="$TMUX_PLUGINS_DIR/$plugin"
        if [ ! -d "$PLUGIN_DIR" ]; then
            echo "  📥 Installing $plugin..."
            git clone --quiet "${PLUGINS[$plugin]}" "$PLUGIN_DIR"
        else
            echo "  ✅ $plugin already installed"
        fi
    done

    echo "✅ All tmux plugins installed"
else
    echo "⚠️  Tmux not found. Skipping TPM installation."
fi

# Run platform-specific installation scripts (Linux only - macOS uses Brewfile)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ARCH="$(uname -m)"  # x86_64, aarch64, etc.
    INSTALL_DIR="$SCRIPT_DIR/install/linux/${ARCH}"

    if [[ -d "$INSTALL_DIR" ]]; then
        echo "Running Linux install scripts in $INSTALL_DIR..."

        # First, run the consolidated common tools script if it exists
        COMMON_TOOLS_SCRIPT="$SCRIPT_DIR/install/linux/common-tools.sh"
        if [[ -f "$COMMON_TOOLS_SCRIPT" ]]; then
            echo "Running consolidated common tools script..."
            bash "$COMMON_TOOLS_SCRIPT"
        fi

        # Then run individual scripts
        for script in "$INSTALL_DIR"/*.sh; do
            if [[ -f "$script" ]]; then
                echo "Running $script..."
                bash "$script"
            fi
        done
    else
        echo "No install directory found for ARCH=$ARCH"
    fi
fi

# Run tmux setup
echo ""
echo "Setting up tmux configuration..."
if [[ -f "$SCRIPT_DIR/tmux/install.sh" ]]; then
    bash "$SCRIPT_DIR/tmux/install.sh"
else
    echo "Warning: tmux install script not found. Skipping tmux setup."
fi

# Run wezterm setup
echo ""
echo "Setting up wezterm configuration..."
if [[ -f "$SCRIPT_DIR/wezterm/install.sh" ]]; then
    bash "$SCRIPT_DIR/wezterm/install.sh"
else
    echo "Warning: wezterm install script not found. Skipping wezterm setup."
fi

# Run starship setup
echo ""
echo "Setting up starship prompt..."
if [[ -f "$SCRIPT_DIR/starship/install.sh" ]]; then
    bash "$SCRIPT_DIR/starship/install.sh"
else
    echo "Warning: starship install script not found. Skipping starship setup."
fi

echo ""
echo "Setup complete!"
