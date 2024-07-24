#!/bin/bash

set -e


# Function to ensure locale is uncommented if the locale.gen files exists
# This is mainly for use on raspberry pi.
check_locale_gen() {
    local file="/etc/locale.gen"
    local locale="en_US.UTF-8"

    if [[ -f $file ]]; then
        if grep -q "^#.*$locale" "$file"; then
            echo "Uncommenting $locale in $file."
            sudo sed -i "s/^#.*$locale/$locale/" "$file"
        fi
    fi
}

# Set timezone info
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime > /etc/timezone

echo -n "Installing APT packages... " | tee -a $LOGFILE

# Update and install packages
apt-get update >> $LOGFILE
apt-get upgrade -y >> $LOGFILE
cat "$AUTOSCRIPT_DIR/apt-package-list.txt" | xargs apt-get install -y >> $LOGFILE

echo "Done!" | tee -a $LOGFILE

echo -n "Setting Locale... " | tee -a $LOGFILE

# Set locale
check_locale_gen
locale-gen en_US.UTF-8 >> $LOGFILE
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

echo "Done!" | tee -a $LOGFILE
