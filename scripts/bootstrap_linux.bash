#!/bin/bash

set -e

# Set timezone to Eastern Time if not already set
if [[ -z "${TZ}" ]]
then
	export TZ=America/New_York
fi
echo "Timezone set to $TZ" | tee -a $LOGFILE

echo "Installing packages from apt-packages-list.txt" | tee -a $LOGFILE
if [ "$EUID" -ne 0 ]
then
	sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime | sudo tee /etc/timezone
	DEBIAN_FRONTEND=noninteractive sudo apt-get update >> $LOGFILE
       	DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y >> $LOGFILE
	cat "$SCRIPT_DIR/apt-package-list.txt" | DEBIAN_FRONTEND=noninteractive sudo xargs apt-get install -y >> $LOGFILE
else
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime > /etc/timezone
	DEBIAN_FRONTEND=noninteractive apt-get update >> $LOGFILE
	DEBIAN_FRONTEND=noninteractive apt-get upgrade -y >> $LOGFILE
	cat "$SCRIPT_DIR/apt-package-list.txt" | DEBIAN_FRONTEND=noninteractive xargs apt-get install -y >> $LOGFILE
fi

echo "Installing latest version of GNU Stow" | tee -a $LOGFILE
$SCRIPT_DIR/stow_install.bash

echo "Installing latest version of Universal Ctags" | tee -a $LOGFILE
$SCRIPT_DIR/uctags_install.bash

# Install oh-my-zsh
$SCRIPT_DIR/ohmyzsh_install.bash

# Stow dotfiles
echo "Deploying dotfiles" | tee -a $LOGFILE
cd $DOTFILE_DIR && stow -R --target=${HOME} --dotfiles .

echo "Installing FZF" | tee -a $LOGFILE
if [[ ! -d "$HOME/.fzf" ]]
then
	git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf >> $LOGFILE
	$HOME/.fzf/install --bin --no-key-bindings --no-completion --no-update-rc >> $LOGFILE
fi

# Rebuild font cache
echo "Rebuilding font cache" | tee -a $LOGFILE
fc-cache -f -v >> $LOGFILE

# Install all vim packages with minpac
# This command will run vim silently, installing all packages and then quitting
echo "Installing vim packages" | tee -a $LOGFILE
vim -E -s -u NONE -N -c "source $HOME/.vim/install_packages.vim"
nvim --headless -c "source $HOME/.config/nvim/install_packages.vim"

# ALL DONE!
echo -e "\n\nBootstrapping complete!" | tee -a $LOGFILE
echo -e "\n--> Restart terminal for all changes to take effect.\n\n" | tee -a $LOGFILE
