#!/bin/bash

set -e

TEMP_DIR="$HOME/uctag_temp"

echo "Installing latest version of Universal Ctags" | tee -a $LOGFILE

mkdir -p $TEMP_DIR && cd $TEMP_DIR
git clone https://github.com/universal-ctags/ctags.git >> $LOGFILE 2>&1
cd ctags
./autogen.sh >> $LOGFILE 2>&1
./configure --prefix=$HOME/.local >> $LOGFILE 2>&1
make -j$(nproc) >> $LOGFILE 2>&1
make install >> $LOGFILE 2>&1
rm -rf $TEMP_DIR
