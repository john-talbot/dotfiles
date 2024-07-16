#!/bin/bash

set -e

TEMP_DIR="$HOME/stow_temp"

# Ensure Test::Output perl module is installed
sudo cpanm Test::Output >> $LOGFILE

# Download and unpack latest stow tarball
# This will all happen in TEMP_DIR for easy cleanup
mkdir -p $TEMP_DIR && cd $TEMP_DIR
curl -O -sS ftp://ftp.gnu.org/gnu/stow/stow-latest.tar.gz >> $LOGFILE
tar -xzvf stow-latest.tar.gz  >> $LOGFILE
rm stow-latest.tar.gz

# Build and install to .local
cd stow-* 
./configure --prefix=$HOME/.local >> $LOGFILE
make >> $LOGFILE
make install >> $LOGFILE
rm -r $TEMP_DIR
