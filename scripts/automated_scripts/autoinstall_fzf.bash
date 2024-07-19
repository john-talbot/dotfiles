#!/bin/bash

set -e

echo "Installing FZF" | tee -a $LOGFILE

if [[ ! -d "$HOME/.fzf" ]]
then
	git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf >> $LOGFILE
	$HOME/.fzf/install --bin --no-key-bindings --no-completion --no-update-rc >> $LOGFILE
fi
