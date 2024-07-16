#!/bin/bash

set -e

TEMP_DIR="$HOME/uctag_temp"

mkdir -p $TEMP_DIR && cd $TEMP_DIR
git clone -q https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh >> $LOGFILE
./configure --prefix=$HOME/.local >> $LOGFILE
make -j$(nproc) >> $LOGFILE
make install >> $LOGFILE
rm -rf $TEMP_DIR
