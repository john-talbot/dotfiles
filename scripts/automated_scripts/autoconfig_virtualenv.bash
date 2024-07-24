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

echo "Done!" | tee -a $LOGFILE
