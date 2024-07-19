#!/bin/bash

set -e

TEMP_DIR="$HOME/neovim_temp"

# Download and unpack latest stow tarball
# This will all happen in TEMP_DIR for easy cleanup

echo "Installing latest version of Neovim" | tee -a $LOGFILE

mkdir -p $TEMP_DIR && cd $TEMP_DIR
#
# Run main script based on OS detected
if [[ "${OS}" == "Linux" ]]; then
    # For now we need the prerelease version (Neovim 0.11.0), we'll change this
    # back to `latest` once this version is stabilized
    # curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz >> $LOGFILE
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz >> $LOGFILE
    rm -rf /opt/nvim-linux64 >> $LOGFILE
    tar -C /opt -xf nvim-linux64.tar.gz >> $LOGFILE
    
    # Install python support
    python3 -m pip install --upgrade neovim

elif [[ "${OS}" == "Darwin" ]]; then
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz >> $LOGFILE
    xattr -c ./nvim-macos-arm64.tar.gz >> $LOGFILE
    sudo rm -rf /opt/nvim-macos-arm64 >> $LOGFILE
    sudo tar -C /opt -xf nvim-macos-arm64.tar.gz >> $LOGFILE

    # Assumes you'll be using a virtualenv in MacOS so no python package installation needed

fi


rm -rf $TEMP_DIR
