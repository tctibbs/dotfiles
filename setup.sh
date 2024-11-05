#!/bin/bash
# Setup file for docker dev containers extension for VS Code

SUDO=""
if [[ "$EUID" -ne 0 ]]; then
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
stow -v -R --target=$HOME zsh

# Verify the symlink for .zshrc as an example
if [[ -L "$HOME/.zshrc" && -f "$HOME/.zshrc" ]]; then
    echo ".zshrc linked successfully."
else
    echo "Error: .zshrc was not linked. Check your stow setup or folder structure."
fi