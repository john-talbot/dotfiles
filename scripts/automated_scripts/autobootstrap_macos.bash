#!/bin/bash

set -e

# Install homebrew
if [[ -e /opt/homebrew/bin/brew ]]; then
    echo "Homebrew is already installed." | tee -a $LOGFILE
else
    echo -n "Homebrew is not installed. Installing Homebrew... " | tee -a $LOGFILE
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> $LOGFILE 2>&1
    echo "Done!" | tee -a $LOGFILE
fi

# Install packages from homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
echo -n "Installing homebrew packages... " | tee -a $LOGFILE
brew bundle install --file "$AUTOSCRIPT_DIR/Brewfile" >> $LOGFILE 2>&1
echo "Done!" | tee -a $LOGFILE

# Disable Apple press and hold for Visual Studio Code
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# Stop Xquartz from automatically opening XTerm
defaults write org.xquartz.X11 app_to_run /usr/bin/true

# Fix package error in Latex Workshop for VSCode
cpanm YAML::Tiny >> $LOGFILE

# Install Neovim
$AUTOSCRIPT_DIR/autoinstall_neovim.bash
