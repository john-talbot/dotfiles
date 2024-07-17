#!/bin/bash

set -e

# Set timezone info
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime > /etc/timezone

# Update and install packages
apt-get update >> $LOGFILE
apt-get upgrade -y >> $LOGFILE
cat "$SCRIPT_DIR/apt-package-list.txt" | xargs apt-get install -y >> $LOGFILE

# Set locale
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
