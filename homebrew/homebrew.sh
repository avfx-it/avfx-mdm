#!/bin/bash
set -e

# Check for CLT
if ! xcode-select -p &>/dev/null; then
  echo "📦 Installing Command Line Tools silently..."

  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  CLT_PACKAGE=$(softwareupdate -l | grep -E '\*.*Command Line Tools' | head -n 1 | awk -F"* " '{print $2}' | sed 's/^ *//')
  softwareupdate -i "$CLT_PACKAGE" --verbose
  rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

  echo "✅ Command Line Tools installed."
else
  echo "✅ Command Line Tools already installed."
fi

echo "🍺 Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "🔄 Setting up Homebrew shell environment..."
BREW_PREFIX="/opt/homebrew"
if [[ ":$PATH:" != *":$BREW_PREFIX/bin:"* ]]; then
  echo "export PATH=\"$BREW_PREFIX/bin:\$PATH\"" >> ~/.zprofile
  export PATH="$BREW_PREFIX/bin:$PATH"
fi

echo "✅ Homebrew installation complete."
