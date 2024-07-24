#!/bin/bash

set -e

TEMP_DIR="$HOME/uctag_temp"

echo -n "Installing latest version of Universal Ctags (This may take a while)... " | tee -a $LOGFILE

mkdir -p $TEMP_DIR && cd $TEMP_DIR
git clone https://github.com/universal-ctags/ctags.git >> $LOGFILE 2>&1
cd ctags
./autogen.sh >> $LOGFILE 2>&1
./configure --prefix=$HOME/.local >> $LOGFILE 2>&1
make -j$(nproc) >> $LOGFILE 2>&1
make install >> $LOGFILE 2>&1
rm -rf $TEMP_DIR

echo "Done!" | tee -a $LOGFILE
