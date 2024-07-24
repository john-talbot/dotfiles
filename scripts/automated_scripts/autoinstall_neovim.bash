#!/bin/bash

set -e

echo -n "Installing latest version of Neovim (This may take a while)... " | tee -a $LOGFILE

TEMP_DIR="$HOME/neovim_temp"

# Download and unpack latest stow tarball
# This will all happen in TEMP_DIR for easy cleanup
mkdir -p $TEMP_DIR && cd $TEMP_DIR

# Run main script based on OS detected
if grep -q Raspberry /proc/cpuinfo; then
    # Neovim doesn't have nightly build for linux-arm64 at this point so build it from source
    rm -rf /opt/neovim >> $LOGFILE
    sudo apt-get install -y -q ninja-build gettext cmake unzip curl build-essential >> $LOGFILE
    git clone --depth 1 -b nightly https://github.com/neovim/neovim.git >> $LOGFILE 2>&1
    cd neovim
    make -j$(nproc) CMAKE_BUILD_TYPE=Release >> $LOGFILE
    sudo make CMAKE_INSTALL_PREFIX=/opt/neovim install >> $LOGFILE

elif [[ "${OS}" == "Linux" ]]; then
    # For now we need the prerelease version (Neovim 0.11.0), we'll change this
    # back to `latest` once this version is stabilized
    # curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz >> $LOGFILE
    rm -rf /opt/neovim >> $LOGFILE
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz >> $LOGFILE
    tar -C /opt -xf nvim-linux64.tar.gz >> $LOGFILE
    mv /opt/nvim-linux64 /opt/neovim

elif [[ "${OS}" == "Darwin" ]]; then
    sudo rm -rf /opt/neovim >> $LOGFILE
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz >> $LOGFILE
    xattr -c ./nvim-macos-arm64.tar.gz >> $LOGFILE
    sudo tar -C /opt -xf nvim-macos-arm64.tar.gz >> $LOGFILE
    sudo mv /opt/nvim-macos-arm64 /opt/neovim
    
fi

rm -rf $TEMP_DIR

echo "Done!" | tee -a $LOGFILE
