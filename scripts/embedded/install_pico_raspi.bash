#!/bin/bash

# Largely taken from Raspberry Pi's official install script, with some modifications 
# for my personal use.

set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
LOGFILE="$SCRIPT_DIR/pico_install.log"

# Empty logfile
cat /dev/null >| $LOGFILE

# This script is only valid on Raspberry Pi computers
if grep -q Raspberry /proc/cpuinfo; then
    echo -e "Running on a Raspberry Pi... Continuing.\n" | tee -a $LOGFILE
else
    echo "Not running on a Raspberry Pi. Exiting!" | tee -a $LOGFILE
    exit 1
fi

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
TEMP_DIR="$HOME/pico_temp"
OUTDIR="$HOME/pico"

GIT_DEPS="git"
SDK_DEPS="cmake gcc-arm-none-eabi gcc g++"
OPENOCD_DEPS="gdb-multiarch automake autoconf build-essential texinfo libtool libftdi-dev libusb-1.0-0-dev"
UART_DEPS="minicom"

# Install all dependencies
echo -n 'Installing dependencies... ' | tee -a $LOGFILE
sudo apt-get update -q >> $LOGFILE 2>&1
sudo apt-get install -q -y $GIT_DEPS $SDK_DEPS $OPENOCD_DEPS $UART_DEPS >> $LOGFILE 2>&1
echo -e 'Done!\n' | tee -a $LOGFILE

# Clone repos from raspberry-pi's GitHub
echo -e "Creating $OUTDIR.\n" | tee -a $LOGFILE
mkdir -p $OUTDIR
cd $OUTDIR

# Clone sw repos
GITHUB_PREFIX="https://github.com/raspberrypi/"
GITHUB_SUFFIX=".git"
SDK_BRANCH="master"

echo -e "Cloning pico repositories to $OUTDIR...\n" | tee -a $LOGFILE
for REPO in sdk examples extras playground
do
    DEST="$OUTDIR/pico-$REPO"

    if [ -d $DEST ]; then
        echo -e "$DEST already exists... Skipping.\n" | tee -a $LOGFILE
    else
        REPO_URL="${GITHUB_PREFIX}pico-${REPO}${GITHUB_SUFFIX}"
        echo -n "Cloning $REPO_URL... " | tee -a $LOGFILE
        git clone -b $SDK_BRANCH $REPO_URL >> $LOGFILE 2>&1

        # Any submodules
        cd $DEST
        git submodule update --init >> $LOGFILE 2>&1
        cd $OUTDIR
        
        echo "Done!" | tee -a $LOGFILE

        # Define PICO_SDK_PATH in ~/.zshenv-per-machine
        VARNAME="PICO_${REPO^^}_PATH"
        echo -e "Adding $VARNAME to ~/.zshenv-per-machine.\n" | tee -a $LOGFILE
        echo "export $VARNAME=$DEST" >> ~/.zshenv-per-machine | tee -a $LOGFILE
        export ${VARNAME}=$DEST
    fi
done
echo -e "Done!\n" | tee -a $LOGFILE

# Picoprobe and picotool
echo -n "Installing picotool and picoprobe... " | tee -a $LOGFILE
for REPO in picoprobe picotool
do
    DEST="$OUTDIR/$REPO"
    REPO_URL="${GITHUB_PREFIX}${REPO}${GITHUB_SUFFIX}"
    git clone $REPO_URL >> $LOGFILE 2>&1

    # Build both
    cd $DEST
    git submodule update --init >> $LOGFILE 2>&1
    mkdir build
    cd build
    cmake ../ >> $LOGFILE 2>&1
    make -j$(nproc) >> $LOGFILE 2>&1

    if [[ "$REPO" == "picotool" ]]; then
        sudo cp picotool $HOME/.local/bin/
    fi

    cd $OUTDIR
done
echo -e "Done!\n" | tee -a $LOGFILE

# OpenOCD
if [ -d openocd ]; then
    echo "OpenOCD already exists... Skipping." | tee -a $LOGFILE
else
    echo -n "Building OpenOCD... " | tee -a $LOGFILE
    cd $OUTDIR
    # Should we include picoprobe support (which is a Pico acting as a debugger for another Pico)
    OPENOCD_BRANCH="rp2040-v0.12.0"
    OPENOCD_CONFIGURE_ARGS="--enable-ftdi --enable-sysfsgpio --enable-bcm2835gpio --enable-picoprobe"

    git clone "${GITHUB_PREFIX}openocd${GITHUB_SUFFIX}" -b $OPENOCD_BRANCH --depth=1 >> $LOGFILE 2>&1
    cd openocd
    ./bootstrap >> $LOGFILE 2>&1
    ./configure $OPENOCD_CONFIGURE_ARGS >> $LOGFILE 2>&1
    make -j$(nproc) >> $LOGFILE 2>&1
    sudo make install >> $LOGFILE 2>&1
    echo "Done!" | tee -a $LOGFILE
fi

# Move custom functions to ~/.zshrc-per-machine
echo -n "Adding custom functions to ~/.zshrc-per-machine... " | tee -a $LOGFILE
cat $SCRIPT_DIR/pico-zshrc >> ~/.zshrc-per-machine
echo "Done!" | tee -a $LOGFILE

# Add user to dialout group
echo -n "Adding current user to dialout group... " | tee -a $LOGFILE
CURRENT_USER=$(whoami)
sudo usermod -aG dialout $CURRENT_USER
echo "Done!" | tee -a $LOGFILE

echo -e "\nInstallation Complete!!" | tee -a $LOGFILE
echo "You must reboot to finish setup" | tee -a $LOGFILE
