#!/bin/bash

set -e

echo -n "Configuring python virtual environment base_env... " | tee -a $LOGFILE

# Create base virtualenv
virtualenv $HOME/base_venv >> $LOGFILE

# Activate virtualenv
source $HOME/base_venv/bin/activate >> $LOGFILE

# Install python packages
cat $AUTOSCRIPT_DIR/python_packages.txt | xargs python3 -m pip install --upgrade >> $LOGFILE

# Deactivate virtualenv
deactivate

# Automatically load base_venv on shell startup
touch $HOME/.zshrc-per-machine
echo "### Python Virtualenv" >> "$HOME/.zshrc-per-machine"
echo 'source $HOME/base_venv/bin/activate' >> "$HOME/.zshrc-per-machine"
echo "" >> "$HOME/.zshrc-per-machine"

echo "Done!" | tee -a $LOGFILE
