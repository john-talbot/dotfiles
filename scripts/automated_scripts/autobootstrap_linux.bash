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

# Install fzf
$AUTOSCRIPT_DIR/autoinstall_fzf.bash

# Rebuild font cache
echo -n "Rebuilding font cache... " | tee -a $LOGFILE
fc-cache -f -v >> $LOGFILE
echo "Done!" | tee -a $LOGFILE
