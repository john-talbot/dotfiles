#!/bin/bash

# Terminate script immediately on any error
set -e

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

# Call the set-git-config.bash script
$AUTOSCRIPT_DIR/autoconfig_git.bash

# ALL DONE!
echo -e "\n\nBootstrapping complete!" | tee -a $LOGFILE
echo -e "\n--> Restart terminal for all changes to take effect.\n\n" | tee -a $LOGFILE
