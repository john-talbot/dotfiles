#!/bin/bash

set -e

# Silently fetch and run install script without any configuration steps
if [[ -e $HOME/.oh-my-zsh/oh-my-zsh.sh ]]; then
	echo "Oh-My-Zsh already installed"
else
	echo "Installing Oh-My-Zsh"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >> $LOGFILE 2>&1
fi

# Remove .zshrc in case it's already there so we can stow our own
if [[ -e "$HOME/.zshrc" ]]
then
    rm ${HOME}/.zshrc
fi
