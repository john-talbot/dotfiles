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
    sudo -E $AUTOSCRIPT_DIR/autoinstall_apt_packages.bash

    echo -n "Changing default shell to zsh... " | tee -a $LOGFILE
    sudo chsh -s /usr/bin/zsh $CURRENT_USER
    echo "Done!" | tee -a $LOGFILE

    sudo -E $AUTOSCRIPT_DIR/autoinstall_neovim.bash
else
    $AUTOSCRIPT_DIR/autoinstall_apt_packages.bash

    echo -n "Changing default shell to zsh... " | tee -a $LOGFILE
    chsh -s /usr/bin/zsh $CURRENT_USER
    echo "Done!" | tee -a $LOGFILE

    $AUTOSCRIPT_DIR/autoinstall_neovim.bash
fi

# Install latest GNU Stow
$AUTOSCRIPT_DIR/autoinstall_stow.bash

# Install latest universal ctags
$AUTOSCRIPT_DIR/autoinstall_uctags.bash

# Install latest treesitter
$AUTOSCRIPT_DIR/autoinstall_treesitter.bash

# Install oh-my-zsh
$AUTOSCRIPT_DIR/autoinstall_ohmyzsh.bash

# Stow dotfiles
echo -n "Deploying dotfiles... " | tee -a $LOGFILE
cd $DOTFILE_DIR && $HOME/.local/bin/stow -R --target=${HOME} --dotfiles .
echo "Done!" | tee -a $LOGFILE

# Install fzf
$AUTOSCRIPT_DIR/autoinstall_fzf.bash

# Setup virtualenv on raspberry pi
# TODO: Figure out a way to exclude just docker builds
if grep -q Raspberry /proc/cpuinfo; then
    $AUTOSCRIPT_DIR/autoconfig_virtualenv.bash
fi

# Rebuild font cache
echo -n "Rebuilding font cache... " | tee -a $LOGFILE
fc-cache -f -v >> $LOGFILE
echo "Done!" | tee -a $LOGFILE

# Install all vim packages with minpac
# This command will run vim silently, installing all packages and then quitting
echo -n "Installing vim & neovim packages..." | tee -a $LOGFILE
vim -E -s -u NONE -N -c "source $HOME/.vim/install_packages.vim" >> $LOGFILE 2>&1
/opt/neovim/bin/nvim --headless -c "source $HOME/.config/nvim/install_packages.vim" >> $LOGFILE 2>&1
echo "Done!" | tee -a $LOGFILE
