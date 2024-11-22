#!/usr/bin/env sh

FONT_NAME="FiraCode Nerd Font"
FONT_SIZE=12

# Check OS
if [ "$(uname)" = "Darwin" ]; then
    echo "macOS detected. Please follow these steps to set the font in iTerm2."

    # Check if iTerm2 is installed
    if ! command -v open >/dev/null 2>&1 || ! open -Ra "iTerm"; then
        echo "iTerm2 is not installed. Please install it from https://iterm2.com."
        exit 1
    fi

    # Open iTerm2 and display instructions
    echo "To set FiraCode Nerd Font manually in iTerm2:"
    echo "1. Open iTerm2."
    echo "2. Go to Preferences > Profiles > Text."
    echo "3. Under 'Font', select FiraCode Nerd Font and set the size to $FONT_SIZE."
    open -a "iTerm"

elif [ "$(uname)" = "Linux" ]; then
    # Linux - Set FiraCode Nerd Font for GNOME Terminal
    if command -v gsettings >/dev/null 2>&1; then
        PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
        if [ -n "$PROFILE" ]; then
            echo "Setting ${FONT_NAME} as the font for GNOME Terminal..."
            gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/" font "${FONT_NAME} ${FONT_SIZE}"
            echo "Font set to ${FONT_NAME} in GNOME Terminal."
        else
            echo "Could not find default GNOME Terminal profile."
        fi
    else
        echo "gsettings command not found. Please ensure you're using GNOME Terminal and have gsettings installed."
    fi

else
    echo "Unsupported OS. This script currently supports only macOS and Linux."
fi
