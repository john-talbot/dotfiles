#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

# Set timezone to Eastern Time if not already set
if [[ -z "${TZ}" ]]
then
	export TZ=America/New_York
fi
echo "Timezone set to $TZ" | tee -a $LOGFILE

CURRENT_USER=$(whoami)
if [ "$EUID" -ne 0 ]
then
    echo "Installing packages from apt-packages-list.txt" | tee -a $LOGFILE
    sudo -E $SCRIPT_DIR/autoinstall_apt_packages.bash

    echo "Changing default shell to zsh" | tee -a $LOGFILE
    sudo chsh -s /usr/bin/zsh $CURRENT_USER

    sudo $SCRIPT_DIR/autoinstall_neovim.bash
else
    echo "Installing packages from apt-packages-list.txt" | tee -a $LOGFILE
    $SCRIPT_DIR/autoinstall_apt_packages.bash

    echo "Changing default shell to zsh" | tee -a $LOGFILE
    chsh -s /usr/bin/zsh $CURRENT_USER

    $SCRIPT_DIR/autoinstall_neovim.bash
fi

# Install latest GNU Stow
$SCRIPT_DIR/autoinstall_stow.bash

# Install latest universal ctags
$SCRIPT_DIR/autoinstall_uctags.bash

# Install latest treesitter
$SCRIPT_DIR/autoinstall_treesitter.bash

# Install oh-my-zsh
$SCRIPT_DIR/autoinstall_ohmyzsh.bash

# Stow dotfiles
echo "Deploying dotfiles" | tee -a $LOGFILE
cd $DOTFILE_DIR && $HOME/.local/bin/stow -R --target=${HOME} --dotfiles .

# Install fzf
$SCRIPT_DIR/autoinstall_fzf.bash

# Rebuild font cache
echo "Rebuilding font cache" | tee -a $LOGFILE
fc-cache -f -v >> $LOGFILE

# Install all vim packages with minpac
# This command will run vim silently, installing all packages and then quitting
echo "Installing vim packages" | tee -a $LOGFILE
vim -E -s -u NONE -N -c "source $HOME/.vim/install_packages.vim"
/opt/nvim-linux64/bin/nvim --headless -c "source $HOME/.config/nvim/install_packages.vim"

# ALL DONE!
echo -e "\n\nBootstrapping complete!" | tee -a $LOGFILE
echo -e "\n--> Restart terminal for all changes to take effect.\n\n" | tee -a $LOGFILE
