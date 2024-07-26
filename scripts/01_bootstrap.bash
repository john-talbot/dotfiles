#!/bin/bash

# Terminate script immediately on any error
set -e

# Set CREATE_VENV to true by default -- disable in docker builds
: ${CREATE_VENV:=1}

export OS="$(uname)"

export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export DOTFILE_DIR="$(dirname $SCRIPT_DIR)"
export AUTOSCRIPT_DIR="$SCRIPT_DIR/automated_scripts"

export LOGFILE="$SCRIPT_DIR/install.log"

# Empty logfile
cat /dev/null >| $LOGFILE

# Run main script based on OS detected
if [[ "${OS}" == "Linux" ]]; then
	echo -e "Executing Linux bootstrapping script!\n\n" | tee -a $LOGFILE
	$AUTOSCRIPT_DIR/autobootstrap_linux.bash

elif [[ "${OS}" == "Darwin" ]]; then
	echo -e "Executing MacOS bootstrapping script!\n\n" | tee -a $LOGFILE
	$AUTOSCRIPT_DIR/autobootstrap_macos.bash
else
	abort "This file only supports macOS and Linux."
fi

# Install oh-my-zsh
$AUTOSCRIPT_DIR/autoinstall_ohmyzsh.bash

# Install node
$AUTOSCRIPT_DIR/autoinstall_node.bash
source "$NVM_DIR/nvm.sh"

# Only create a virtualenv if 
if [ "$CREATE_VENV" -ne 0 ]; then
    $AUTOSCRIPT_DIR/autoconfig_virtualenv.bash
else
    echo "CREATE_VENV is false so not creating virtualenv." | tee -a $LOGFILE
fi

# Stow dotfiles
echo -n "Deploying dotfiles... " | tee -a $LOGFILE
cd $DOTFILE_DIR && stow -R --target=$HOME --dotfiles .
echo "Done!" | tee -a $LOGFILE

# Install all vim packages with minpac
# This command will run vim silently, installing all packages and then quitting
echo -n "Installing vim & neovim packages... " | tee -a $LOGFILE
vim -E -s -u NONE -N -c "source $HOME/.vim/install_packages.vim" >> $LOGFILE 2>&1
/opt/neovim/bin/nvim --headless -c "source $HOME/.config/nvim/install_packages.vim" >> $LOGFILE 2>&1
echo "Done!" | tee -a $LOGFILE

# Call the set-git-config.bash script
$AUTOSCRIPT_DIR/autoconfig_git.bash "$@"

# ALL DONE!
echo -e "\n\nBootstrapping complete!" | tee -a $LOGFILE
echo -e "\n--> Restart terminal for all changes to take effect.\n\n" | tee -a $LOGFILE
