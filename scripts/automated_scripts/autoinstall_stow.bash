#!/bin/bash

set -e

TEMP_DIR="$HOME/stow_temp"

echo -n "Installing latest version of GNU Stow... " | tee -a $LOGFILE

# Download and unpack latest stow tarball
# This will all happen in TEMP_DIR for easy cleanup
mkdir -p $TEMP_DIR && cd $TEMP_DIR
curl -O -sS ftp://ftp.gnu.org/gnu/stow/stow-latest.tar.gz >> $LOGFILE
tar -xzvf stow-latest.tar.gz  >> $LOGFILE
rm stow-latest.tar.gz

# Build and install to .local
cd stow-* 
./configure --prefix=$HOME/.local >> $LOGFILE 2>&1
make -j$(nproc) >> $LOGFILE 2>&1
make install >> $LOGFILE 2>&1
rm -r $TEMP_DIR

echo "Done!" | tee -a $LOGFILE
