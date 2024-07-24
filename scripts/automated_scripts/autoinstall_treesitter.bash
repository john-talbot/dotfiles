#!/bin/bash

set -e

TEMP_DIR="$HOME/treesitter_temp"

echo -n "Installing treesitter... " | tee -a $LOGFILE

ARCH="linux-x64"
if grep -q Raspberry /proc/cpuinfo; then
    ARCH="linux-arm64"
fi

# Download and unpack latest stow tarball
# This will all happen in TEMP_DIR for easy cleanup
mkdir -p $TEMP_DIR && cd $TEMP_DIR

curl -LO "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-$ARCH.gz" >> $LOGFILE
gunzip "tree-sitter-$ARCH.gz"
mv "tree-sitter-$ARCH" $HOME/.local/bin/tree-sitter && chmod +x $HOME/.local/bin/tree-sitter

rm -rf $TEMP_DIR

