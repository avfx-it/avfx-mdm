#!/bin/bash
echo "Installing HandBrake..."
brew install --cask handbrake-app

# Confirm installation
if [ -d "/Applications/HandBrake.app" ]; then
    echo "✅ HandBrake installed successfully."
else
    echo "❌ HandBrake installation failed."
fi

# Icon at https://github.com/avfx-it/avfx-mdm/blob/main/images/handbrake.png
