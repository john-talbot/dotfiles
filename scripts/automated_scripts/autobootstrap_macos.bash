#!/bin/bash
echo "Installing latest version of Neovim" | tee -a $LOGFILE

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
brew bundle install --file "$AUTOSCRIPT_DIR/Brewfile" | tee -a $LOGFILE 2>&1
echo "Done!" | tee -a $LOGFILE

# Disable Apple press and hold for Visual Studio Code
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# Stop Xquartz from automatically opening XTerm
defaults write org.xquartz.X11 app_to_run /usr/bin/true

# Fix package error in Latex Workshop for VSCode
cpanm YAML::Tiny >> $LOGFILE

# Setup python virtualenv
$AUTOSCRIPT_DIR/autoconfig_virtualenv.bash

# Install oh-my-zsh
$AUTOSCRIPT_DIR/autoinstall_ohmyzsh.bash

# Install Neovim
$AUTOSCRIPT_DIR/autoinstall_neovim.bash

# Stow dotfiles
echo -n "Deploying dotfiles... " | tee -a $LOGFILE
cd $DOTFILE_DIR && stow -R --target=$HOME --dotfiles .
echo "Done!" | tee -a $LOGFILE

# Install all vim packages with minpac
# This command will run vim silently, installing all packages and then quitting
echo -n "Installing vim & neovim packages..." | tee -a $LOGFILE
vim -E -s -u NONE -N -c "source $HOME/.vim/install_packages.vim" >> $LOGFILE
/opt/neovim/bin/nvim --headless -c "source $HOME/.config/nvim/install_packages.vim" >> $LOGFILE
echo "Done!" | tee -a $LOGFILE
