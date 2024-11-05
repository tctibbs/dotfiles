#!/usr/bin/env sh

# Set fonts directory from script argument or default location
FONTS_DIR=${1:-"$HOME/.local/share/fonts"}

# FiraCode Nerd Font URL and version
NERD_FONT_VERSION="2.3.3"
FIRA_CODE_NERD_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}/FiraCode.zip"

# Create fonts directory if it doesn't exist
if [ ! -d "${FONTS_DIR}" ]; then
    echo "Creating fonts directory at ${FONTS_DIR}..."
    mkdir -p "${FONTS_DIR}"
else
    echo "Fonts directory found at ${FONTS_DIR}"
fi

# Download and install FiraCode Nerd Font
echo "Downloading FiraCode Nerd Font..."
curl -L --fail --show-error "$FIRA_CODE_NERD_URL" -o "FiraCode.zip"

if [ $? -ne 0 ]; then
    echo "Failed to download FiraCode Nerd Font. Check your internet connection or URL."
    exit 1
fi

echo "Extracting FiraCode Nerd Font..."
unzip -o -q -d "${FONTS_DIR}" "FiraCode.zip"
rm "FiraCode.zip"  # Clean up zip file

echo "FiraCode Nerd Font installed successfully in ${FONTS_DIR}"

# Refresh font cache (Linux only)
if [ "$(uname)" = "Linux" ]; then
    echo "Updating font cache..."
    fc-cache -fv "${FONTS_DIR}"
else
    echo "Font cache updated automatically on macOS"
fi
