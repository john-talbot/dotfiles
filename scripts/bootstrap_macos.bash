#!/bin/bash

set -e

# Install homebrew
if [[ -e /opt/homebrew/bin/brew ]]; then
    echo "Homebrew is already installed." | tee -a $LOGFILE
else
    echo "Homebrew is not installed. Installing Homebrew..." | tee -a $LOGFILE
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> $LOGFILE 2>&1
fi

# Install packages from homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
echo "Installing homebrew packages..." | tee -a $LOGFILE
brew bundle install --file "$SCRIPT_DIR/Brewfile" | tee -a $LOGFILE 2>&1

# Disable Apple press and hold for Visual Studio Code
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# Stop Xquartz from automatically opening XTerm
defaults write org.xquartz.X11 app_to_run /usr/bin/true

# Fix package error in Latex Workshop for VSCode
cpanm YAML::Tiny

# Install oh-my-zsh
$SCRIPT_DIR/ohmyzsh_install.bash

echo "Installing latest version of Neovim" | tee -a $LOGFILE
$SCRIPT_DIR/neovim_install.bash

# Stow dotfiles
echo "Deploying dotfiles" | tee -a $LOGFILE
cd $DOTFILE_DIR && stow -R --target=$HOME --dotfiles .

# Install all vim packages with minpac
# This command will run vim silently, installing all packages and then quitting
echo "Installing vim packages" | tee -a $LOGFILE
vim -E -s -u NONE -N -c "source $HOME/.vim/install_packages.vim"
nvim --headless -c "source $HOME/.config/nvim/install_packages.vim"

# ALL DONE!
echo -e "\n\nBootstrapping complete!" | tee -a $LOGFILE
echo -e "\n--> Restart terminal for all changes to take effect.\n\n" | tee -a $LOGFILE
