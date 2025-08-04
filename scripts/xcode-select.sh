#!/bin/zsh

DIALOG="/usr/local/bin/dialog"

# Launch SwiftDialog in background, locked and without quit options
$DIALOG \
--title none \
--centreicon \
--icon "https://storage.googleapis.com/avfx_public/mosyle-mdm/images/avfx.png" \
--message "Please wait while we prepare to configure this Mac..." \
--messagealignment center \
--messageposition center \
--messagefont size=32 \
--progress 1 \
--ontop \
--button1disabled \
--button2disabled &
DIALOG_PID=$!

# Give dialog a moment to appear
sleep 1

###############################################################################
## YOUR SCRIPT GOES HERE
###############################################################################

# To check that try to print the SDK path
xcode-select -p &> /dev/null
if [ $? -ne 0 ]; then
  echo "Command Line Tools for Xcode not found. Installing from softwareupdate…"
# This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
  PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
  softwareupdate -i "$PROD" --verbose;
else
  echo "Command Line Tools for Xcode have been installed."
fi

###############################################################################
## END OF YOUR SCRIPT
###############################################################################

# Kill SwiftDialog
pkill -x Dialog
exit 0
