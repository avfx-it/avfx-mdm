#!/bin/bash
echo "Installing Google Chrome..."
brew install --cask google-chrome

# Confirm installation
if [ -d "/Applications/Google Chrome.app" ]; then
    echo "✅ Google Chrome installed successfully."
else
    echo "❌ Google Chrome installation failed."
fi

# Icon at https://github.com/avfx-it/avfx-mdm/blob/main/images/chrome.png
