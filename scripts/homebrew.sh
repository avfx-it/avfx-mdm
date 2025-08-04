#!/bin/bash
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Kill SwiftDialog
pkill -x Dialog
exit 0
