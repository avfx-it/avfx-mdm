#!/bin/bash
set -e

# Function to check if CLT is installed
has_clt() {
  xcode-select -p &>/dev/null
}

echo "🔧 Checking for Xcode Command Line Tools (CLT)..."

if has_clt; then
  echo "✅ Command Line Tools already installed."
else
  echo "📦 Installing Command Line Tools..."
  xcode-select --install

  echo "⏳ Waiting for Command Line Tools installation to complete..."
  # Wait until the tools are installed
  until has_clt; do
    sleep 5
  done
  echo "✅ Command Line Tools installation complete."
fi

echo "🍺 Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "🔄 Setting up Homebrew shell environment..."

# Add Homebrew to PATH (for Apple Silicon)
BREW_PREFIX="/opt/homebrew"
if [[ ":$PATH:" != *":$BREW_PREFIX/bin:"* ]]; then
  echo "export PATH=\"$BREW_PREFIX/bin:\$PATH\"" >> ~/.zprofile
  export PATH="$BREW_PREFIX/bin:$PATH"
fi

echo "✅ Homebrew installation complete. Run 'brew doctor' to verify."
