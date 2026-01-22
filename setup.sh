#!/bin/bash
# Dotfiles setup script with install profiles
#
# Usage:
#   ./setup.sh           # Interactive prompt
#   ./setup.sh full      # Full install (GUI apps, fonts, all tools)
#   ./setup.sh lite      # Lite install (CLI tools only, no GUI)
#   ./setup.sh minimal   # Minimal (just shell/git config)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Profile selection
PROFILE="${1:-}"

if [[ -z "$PROFILE" ]]; then
    echo -e "${BLUE}Select install profile:${NC}"
    echo "  1) full    - Everything: GUI apps, fonts, all CLI tools"
    echo "  2) lite    - All CLI tools, skip GUI apps and fonts"
    echo "  3) minimal - Just shell and git config"
    echo ""
    select PROFILE in "full" "lite" "minimal"; do
        [[ -n "$PROFILE" ]] && break
    done
fi

# Validate profile
if [[ ! "$PROFILE" =~ ^(full|lite|minimal)$ ]]; then
    echo -e "${YELLOW}Invalid profile: $PROFILE${NC}"
    echo "Valid profiles: full, lite, minimal"
    exit 1
fi

echo -e "${GREEN}Installing with profile: $PROFILE${NC}"
echo ""

# Sudo detection - only set CAN_SUDO if we can use sudo without password prompt
SUDO=""
CAN_SUDO="false"
if [ "$EUID" -eq 0 ]; then
    # Running as root
    CAN_SUDO="true"
elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
    # sudo available and doesn't require password
    SUDO="sudo"
    CAN_SUDO="true"
fi

# Ensure ~/.local/bin exists and is in PATH
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# Detect OS and install base packages
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ "$CAN_SUDO" == "true" ]]; then
        echo -e "${BLUE}Installing base packages via apt...${NC}"
        $SUDO apt update
        $SUDO apt install -y zsh stow git
    else
        echo -e "${YELLOW}No sudo access - assuming zsh/stow/git are available${NC}"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Check if Homebrew is installed, install if missing
    if ! command -v brew &>/dev/null; then
        echo -e "${BLUE}Homebrew not found. Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add brew to PATH for Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi

    # Install packages via Brewfile (skip for minimal)
    if [[ "$PROFILE" != "minimal" ]] && [[ -f "$SCRIPT_DIR/homebrew/install.sh" ]]; then
        bash "$SCRIPT_DIR/homebrew/install.sh" "$PROFILE"
    else
        # Minimal: just install essentials
        brew install zsh stow git
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

# Install Tmux Plugin Manager (TPM) and plugins (skip for minimal)
if [[ "$PROFILE" != "minimal" ]] && command -v tmux &>/dev/null; then
    TMUX_PLUGINS_DIR="$HOME/.tmux/plugins"
    mkdir -p "$TMUX_PLUGINS_DIR"

    # Install TPM itself
    TPM_DIR="$TMUX_PLUGINS_DIR/tpm"
    if [ ! -d "$TPM_DIR" ]; then
        echo "Installing Tmux Plugin Manager (TPM)..."
        git clone --quiet https://github.com/tmux-plugins/tpm "$TPM_DIR"
        echo -e "${GREEN}TPM installed${NC}"
    else
        echo -e "${GREEN}TPM is already installed${NC}"
    fi

    # Install plugins directly (same plugins as configured in .tmux.conf)
    echo "Installing tmux plugins..."

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
            echo "  Installing $plugin..."
            git clone --quiet "${PLUGINS[$plugin]}" "$PLUGIN_DIR"
        else
            echo "  $plugin already installed"
        fi
    done

    echo -e "${GREEN}All tmux plugins installed${NC}"
elif [[ "$PROFILE" == "minimal" ]]; then
    echo "Skipping tmux plugins (minimal profile)"
else
    echo -e "${YELLOW}Tmux not found. Skipping TPM installation.${NC}"
fi

# Run platform-specific installation scripts (Linux only, skip for minimal)
if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ "$PROFILE" != "minimal" ]]; then
    ARCH="$(uname -m)"  # x86_64, aarch64, etc.
    INSTALL_DIR="$SCRIPT_DIR/install/linux/${ARCH}"

    if [[ -d "$INSTALL_DIR" ]]; then
        echo -e "${BLUE}Running Linux install scripts...${NC}"

        # First, run the consolidated common tools script if it exists
        COMMON_TOOLS_SCRIPT="$SCRIPT_DIR/install/linux/common-tools.sh"
        if [[ -f "$COMMON_TOOLS_SCRIPT" ]]; then
            echo "Running consolidated common tools script..."
            CAN_SUDO=$CAN_SUDO bash "$COMMON_TOOLS_SCRIPT"
        fi

        # Then run individual scripts
        for script in "$INSTALL_DIR"/*.sh; do
            if [[ -f "$script" ]]; then
                echo "Running $script..."
                CAN_SUDO=$CAN_SUDO bash "$script"
            fi
        done
    else
        echo -e "${YELLOW}No install directory found for ARCH=$ARCH${NC}"
    fi
fi

# Run tmux setup (skip for minimal - just uses the stowed config)
if [[ "$PROFILE" != "minimal" ]]; then
    echo ""
    echo -e "${BLUE}Setting up tmux configuration...${NC}"
    if [[ -f "$SCRIPT_DIR/tmux/install.sh" ]]; then
        bash "$SCRIPT_DIR/tmux/install.sh"
    else
        echo -e "${YELLOW}Warning: tmux install script not found. Skipping tmux setup.${NC}"
    fi
fi

# Run wezterm setup (full profile only - requires GUI)
if [[ "$PROFILE" == "full" ]]; then
    echo ""
    echo -e "${BLUE}Setting up wezterm configuration...${NC}"
    if [[ -f "$SCRIPT_DIR/wezterm/install.sh" ]]; then
        bash "$SCRIPT_DIR/wezterm/install.sh"
    else
        echo -e "${YELLOW}Warning: wezterm install script not found. Skipping wezterm setup.${NC}"
    fi
fi

# Run ghostty setup (full profile only - requires GUI)
if [[ "$PROFILE" == "full" ]]; then
    if [[ -f "$SCRIPT_DIR/ghostty/install.sh" ]]; then
        bash "$SCRIPT_DIR/ghostty/install.sh"
    fi
fi

# Run starship setup (skip for minimal)
if [[ "$PROFILE" != "minimal" ]]; then
    echo ""
    echo -e "${BLUE}Setting up starship prompt...${NC}"
    if [[ -f "$SCRIPT_DIR/starship/install.sh" ]]; then
        bash "$SCRIPT_DIR/starship/install.sh"
    else
        echo -e "${YELLOW}Warning: starship install script not found. Skipping starship setup.${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Setup complete! (profile: $PROFILE)${NC}"
echo ""
if [[ "$PROFILE" == "minimal" ]]; then
    echo "Minimal install done. Shell config is ready."
    echo "Run with 'lite' or 'full' profile to install CLI tools."
fi
