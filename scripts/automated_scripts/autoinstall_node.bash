#!/bin/bash

set -e

echo -n "Installing latest version of node... " | tee -a $LOGFILE

# Get the latest tag
tag_name=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.tag_name')
URL="https://raw.githubusercontent.com/nvm-sh/nvm/$tag_name/install.sh" 

touch "$HOME/.zshrc-per-machine"
curl -sSo- "$URL" | PROFILE="$HOME/.zshrc-per-machine" bash >> $LOGFILE 2>&1

NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"

nvm install node >> $LOGFILE 2>&1

echo "Done!" | tee -a $LOGFILE
