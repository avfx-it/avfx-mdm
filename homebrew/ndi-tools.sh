#!/bin/bash
echo "Installing NDI Tools..."
/opt/homebrew/bin/brew install --cask ndi-tools

# Confirm installation
if [ -d "/Applications/NDI Tools.app" ]; then
    echo "✅ NDI Tools installed successfully."
else
    echo "❌ NDI Tools installation failed."
fi

# Icon at https://github.com/avfx-it/avfx-mdm/blob/main/images/acrobat.png
