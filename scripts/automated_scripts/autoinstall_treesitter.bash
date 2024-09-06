#!/bin/bash

set -e

TEMP_DIR="$HOME/treesitter_temp"

echo -n "Installing treesitter... " | tee -a $LOGFILE

BRANCH="linux-x64"
if grep -q Raspberry /proc/cpuinfo; then
    ARCH=$(uname -m)
    if [ "$ARCH" = "aarch64" ]; then
        BRANCH="linux-arm64"
    elif [ "$ARCH" = "armv7l" ]; then
        BRANCH="linux-arm"
    else
        abort "Unrecognized architecture"
    fi
fi

# Download and unpack latest stow tarball
# This will all happen in TEMP_DIR for easy cleanup
mkdir -p $TEMP_DIR && cd $TEMP_DIR

curl -sSLO "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-$BRANCH.gz" >> $LOGFILE
gunzip "tree-sitter-$BRANCH.gz"
mv "tree-sitter-$BRANCH" $HOME/.local/bin/tree-sitter && chmod +x $HOME/.local/bin/tree-sitter

rm -rf $TEMP_DIR

echo "Done!" | tee -a $LOGFILE
