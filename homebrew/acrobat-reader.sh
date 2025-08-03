#!/bin/bash
echo "Installing Adobe Acrobat Reader..."
/opt/homebrew/bin/brew install --cask adobe-acrobat-reader

# Confirm installation
if [ -d "/Applications/Adobe Acrobat Reader.app" ]; then
    echo "✅ Adobe Acrobat Reader installed successfully."
else
    echo "❌ Adobe Acrobat Reader installation failed."
fi

# Icon at https://github.com/avfx-it/avfx-mdm/blob/main/images/acrobat.png
