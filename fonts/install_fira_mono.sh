#!/usr/bin/env sh

# Get the fonts directory from the main script argument
FONTS_DIR=$1

# Define the Nerd Font version and download URL for Fira Mono
NERD_FONT_VERSION="3.2.1"
FONT_NAME="FiraMono"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}/${FONT_NAME}.zip"

# Download and install Fira Mono Nerd Font
echo "Downloading Fira Mono Nerd Font..."
curl -L --fail --show-error "${FONT_URL}" -o "${FONT_NAME}.zip"

# Check if download succeeded
if [ $? -ne 0 ]; then
    echo "Failed to download Fira Mono Nerd Font. Check your internet connection or URL."
    exit 1
fi

echo "Extracting Fira Mono Nerd Font..."
unzip -o -q -d "${FONTS_DIR}" "${FONT_NAME}.zip"
rm "${FONT_NAME}.zip"

echo "Fira Mono Nerd Font installed successfully in ${FONTS_DIR}"
