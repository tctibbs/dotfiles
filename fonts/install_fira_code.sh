#!/usr/bin/env sh

# Get fonts directory from main script argument
FONTS_DIR=$1
FIRA_CODE_VERSION="6.2"
FIRA_CODE_URL="https://github.com/tonsky/FiraCode/releases/download/$FIRA_CODE_VERSION/Fira_Code_v${FIRA_CODE_VERSION}.zip"

# Download and install Fira Code
echo "Downloading Fira Code..."
curl -L --fail --show-error "${FIRA_CODE_URL}" -o "Fira_Code.zip"

if [ $? -ne 0 ]; then
    echo "Failed to download Fira Code. Check your internet connection or URL."
    exit 1
fi

echo "Extracting Fira Code..."
unzip -o -q -d "${FONTS_DIR}" "Fira_Code.zip"
rm "Fira_Code.zip"  # Clean up zip file

echo "Fira Code installed successfully in ${FONTS_DIR}"
