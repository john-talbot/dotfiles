#!/bin/bash

# Terminate script immediately on any error
set -e

export OS="$(uname)"
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export DOTFILE_DIR="$(dirname $SCRIPT_DIR)"
export LOGFILE="$SCRIPT_DIR/install.log"
# export LOGFILE=/dev/stdout

# Empty logfile
cat /dev/null >| $LOGFILE

# Run main script based on OS detected
if [[ "${OS}" == "Linux" ]]; then
	echo "Calling Linux bootstrapping" | tee -a $LOGFILE
	$SCRIPT_DIR/bootstrap_linux.bash

elif [[ "${OS}" == "Darwin" ]]; then
	echo "Calling MacOS bootstrapping" | tee -a $LOGFILE
	$SCRIPT_DIR/bootstrap_macos.bash
else
	abort "This file only supports macOS and Linux."
fi
