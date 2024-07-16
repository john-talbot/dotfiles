#!/bin/bash

set -e

TEMP_DIR="$HOME/neovim_temp"

# Download and unpack latest stow tarball
# This will all happen in TEMP_DIR for easy cleanup
mkdir -p $TEMP_DIR && cd $TEMP_DIR
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz >> $LOGFILE
sudo rm -rf /opt/nvim >> $LOGFILE
sudo tar -C /opt -xzf nvim-linux64.tar.gz >> $LOGFILE
rm -rf $TEMP_DIR
