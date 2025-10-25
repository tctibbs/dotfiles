#!/bin/bash
# Setup file for docker dev containers extension for VS Code

SUDO=""
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
fi

# Detect OS and use the appropriate package manager
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    $SUDO apt update
    $SUDO apt install -y zsh stow
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Check if Homebrew is installed, install if missing
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install zsh and stow via Homebrew
    brew install zsh stow
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

# Create ~/.config/zsh directory and link additional config files
echo "Creating ~/.config/zsh directory and linking additional config files..."
mkdir -p "$HOME/.config/zsh"
ln -sf "$HOME/Code/dotfiles/zsh/aliash.zsh" "$HOME/.config/zsh/aliash.zsh"

# Ensure p10k configuration is linked
if [ -f "$HOME/dotfiles/zsh/.p10k.zsh" ]; then
    echo "Linking Powerlevel10k configuration with stow..."
    stow -v -R --target="$HOME" zsh
else
    echo "Warning: Powerlevel10k configuration file not found in zsh folder. Skipping."
fi

# Verify the symlink for .zshrc and .p10k.zsh
if [ -L "$HOME/.zshrc" ] && [ -f "$HOME/.zshrc" ]; then
    echo ".zshrc linked successfully."
else
    echo "Error: .zshrc was not linked. Check your stow setup or folder structure."
fi

if [ -L "$HOME/.p10k.zsh" ] && [ -f "$HOME/.p10k.zsh" ]; then
    echo ".p10k.zsh linked successfully."
else
    echo "Warning: .p10k.zsh was not linked. Check your stow setup or folder structure."
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

# Run all installation scripts
# Detect OS and architecture for platform-specific installs
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"  # linux or darwin
ARCH="$(uname -m)"                             # x86_64, aarch64, etc.
INSTALL_DIR="./install/${OS}/${ARCH}"

if [[ -d "$INSTALL_DIR" ]]; then
    echo "Running platform-specific install scripts in $INSTALL_DIR..."
    
    # First, run the consolidated common tools script if it exists
    COMMON_TOOLS_SCRIPT="./install/${OS}/common-tools.sh"
    if [[ -f "$COMMON_TOOLS_SCRIPT" ]]; then
        echo "Running consolidated common tools script..."
        bash "$COMMON_TOOLS_SCRIPT"
    fi
    
    # Then run individual scripts, excluding the ones handled by common-tools.sh
    for script in "$INSTALL_DIR"/*.sh; do
        if [[ -f "$script" ]]; then
            # Skip individual scripts that are now handled by common-tools.sh
            SCRIPT_NAME=$(basename "$script")
            case "$SCRIPT_NAME" in
                "btop.sh"|"tldr.sh"|"bat.sh"|"zoxide.sh")
                    echo "Skipping $SCRIPT_NAME (handled by common-tools.sh)..."
                    continue
                    ;;
            esac
            
            echo "Running $script..."
            bash "$script"
        fi
    done
else
    echo "No install directory found for OS=$OS ARCH=$ARCH"
fi