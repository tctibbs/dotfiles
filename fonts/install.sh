#!/usr/bin/env sh

# Get the directory of the install.sh script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Determine fonts directory based on OS
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS font directory
    FONTS_DIR="${HOME}/Library/Fonts"
elif [[ "$(uname)" == "Linux" ]]; then
    # Linux font directory (user-specific)
    FONTS_DIR="${HOME}/.local/share/fonts"
else
    echo "Unsupported OS. This script only works on macOS and Linux."
    exit 1
fi

# Create fonts directory if it doesn’t exist
if [ ! -d "${FONTS_DIR}" ]; then
    echo "Creating fonts directory at $FONTS_DIR..."
    mkdir -p "${FONTS_DIR}"
else
    echo "Fonts directory found at $FONTS_DIR"
fi

# Find and run all install scripts located in the same directory as install.sh
echo "Starting font installations..."
for script in "${SCRIPT_DIR}"/install_*.sh; do
    if [[ -x "$script" ]]; then
        echo "Running $script..."
        source "$script" "$FONTS_DIR"
    else
        echo "Skipping $script (not executable)"
    fi
done

# Refresh font cache if on Linux
if [[ "$(uname)" == "Linux" ]]; then
    echo "Updating Linux font cache..."
    fc-cache -fv "${FONTS_DIR}"
else
    echo "Font cache updated automatically on macOS"
fi

echo "Font installation process complete!"

# Run the setup_font.sh script if it's executable
echo "Starting font setup..."
SETUP_SCRIPT="${SCRIPT_DIR}/setup_font.sh"
if [[ -x "$SETUP_SCRIPT" ]]; then
    echo "Running $SETUP_SCRIPT..."
    source "$SETUP_SCRIPT" "$FONTS_DIR"
else
    echo "Error: $SETUP_SCRIPT not found or not executable."
    exit 1
fi
echo "Font setup process complete!"