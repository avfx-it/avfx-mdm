#!/bin/bash
TARGET_USER="avfx"
HOMEBREW_PATH="/opt/homebrew/bin/brew"

echo "Installing Google Chrome..."

su -l "$TARGET_USER" -c "$HOMEBREW_PATH" install --cask google-chrome

# Confirm installation
if [ -d "/Applications/Google Chrome.app" ]; then
    echo "✅ Google Chrome installed successfully."
else
    echo "❌ Google Chrome installation failed."
fi

# Icon at https://github.com/avfx-it/avfx-mdm/blob/main/images/chrome.png
