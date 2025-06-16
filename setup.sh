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

# Run all installation scripts
# Detect OS and architecture for platform-specific installs
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"  # linux or darwin
ARCH="$(uname -m)"                             # x86_64, aarch64, etc.
INSTALL_DIR="./install/${OS}/${ARCH}"

if [[ -d "$INSTALL_DIR" ]]; then
    echo "Running platform-specific install scripts in $INSTALL_DIR..."
    for script in "$INSTALL_DIR"/*.sh; do
        if [[ -f "$script" ]]; then
            echo "Running $script..."
            bash "$script"
        fi
    done
else
    echo "No install directory found for OS=$OS ARCH=$ARCH"
fi
