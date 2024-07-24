#!/bin/bash

set -e

echo -n "Installing FZF... " | tee -a $LOGFILE

if [[ ! -d "$HOME/.fzf" ]]
then
	git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf >> $LOGFILE 2>&1 
	$HOME/.fzf/install --bin --no-key-bindings --no-completion --no-update-rc >> $LOGFILE 2>&1
fi

echo "Done!" | tee -a $LOGFILE
