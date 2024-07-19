#!/bin/bash

set -e

TEMP_DIR="$HOME/treesitter_temp"

echo "Installing treesitter" | tee -a $LOGFILE

# Download and unpack latest stow tarball
# This will all happen in TEMP_DIR for easy cleanup
mkdir -p $TEMP_DIR && cd $TEMP_DIR

curl -LO https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz >> $LOGFILE
gunzip tree-sitter-linux-x64.gz
mv tree-sitter-linux-x64 $HOME/.local/bin/tree-sitter && chmod +x $HOME/.local/bin/tree-sitter

rm -rf $TEMP_DIR

