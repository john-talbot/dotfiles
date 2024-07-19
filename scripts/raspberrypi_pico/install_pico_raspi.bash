#!/bin/bash

# Largely taken from Raspberry Pi's official install script, with some modifications 
# for my personal use.


set -e

# This script is only valid on Raspberry Pi computers
if grep -q Raspberry /proc/cpuinfo; then
    echo "Running on a Raspberry Pi"
else
    echo "Not running on a Raspberry Pi. Exiting!"
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
echo -n 'Installing dependencies... '
sudo apt-get update -q && sudo apt-get install -q -y "$GIT_DEPS $SDK_DEPS $OPENOCD_DEPS $UART_DEPS"
echo 'Done!'

sudo apt install -y $UART_DEPS
echo "Disabling Linux serial console (UART) so we can use it for pico"
sudo raspi-config nonint do_serial 2

# Clone repos from raspberry-pi's GitHub
echo "Creating $OUTDIR"
mkdir -p $OUTDIR
cd $OUTDIR

# Clone sw repos
GITHUB_PREFIX="https://github.com/raspberrypi/"
GITHUB_SUFFIX=".git"
SDK_BRANCH="master"

echo 'Cloning pico repositories'
for REPO in sdk examples extras playground
do
    DEST="$OUTDIR/pico-$REPO"

    if [ -d $DEST ]; then
        echo "$DEST already exists so skipping"
    else
        REPO_URL="${GITHUB_PREFIX}pico-${REPO}${GITHUB_SUFFIX}"
        echo "Cloning $REPO_URL"
        git clone -b $SDK_BRANCH $REPO_URL

        # Any submodules
        cd $DEST
        git submodule update --init
        cd $OUTDIR
        
        # Define PICO_SDK_PATH in ~/.zshenv-per-machine
        VARNAME="PICO_${REPO^^}_PATH"
        echo "Adding $VARNAME to ~/.zshenv-per-machine"
        echo "export $VARNAME=$DEST" >> ~/.zshenv-per-machine
        export ${VARNAME}=$DEST
    fi
done

# Picoprobe and picotool
for REPO in picoprobe picotool
do
    DEST="$OUTDIR/$REPO"
    REPO_URL="${GITHUB_PREFIX}${REPO}${GITHUB_SUFFIX}"
    git clone $REPO_URL

    # Build both
    cd $DEST
    git submodule update --init
    mkdir build
    cd build
    cmake ../
    make -j$(nproc)

    if [[ "$REPO" == "picotool" ]]; then
        echo "Installing picotool to /usr/local/bin/picotool"
        sudo cp picotool /usr/local/bin/
    fi

    cd $OUTDIR
done

# OpenOCD
if [ -d openocd ]; then
    echo "openocd already exists so skipping"
else
    echo "Building OpenOCD"
    cd $OUTDIR
    # Should we include picoprobe support (which is a Pico acting as a debugger for another Pico)
    OPENOCD_BRANCH="rp2040-v0.12.0"
    OPENOCD_CONFIGURE_ARGS="--enable-ftdi --enable-sysfsgpio --enable-bcm2835gpio --enable-picoprobe"

    git clone "${GITHUB_PREFIX}openocd${GITHUB_SUFFIX}" -b $OPENOCD_BRANCH --depth=1
    cd openocd
    ./bootstrap
    ./configure $OPENOCD_CONFIGURE_ARGS
    make -j$(nproc)
    sudo make install
fi

# Move custom functions to ~/.zshrc-per-machine
echo "Adding custom functions to ~/.zshrc-per-machine"
cat $SCRIPT_DIR/pico-zshrc >> ~/.zshrc-per-machine

# Add user to dialout group
echo "Adding current user to dialout group"
CURRENT_USER=$(whoami)
sudo usermod -aG dialout $CURRENT_USER

echo "You must reboot to finish setup"
