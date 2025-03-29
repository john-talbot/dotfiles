#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CONF_DIR="$SCRIPT_DIR/conf"

sudo apt-get update && sudo apt-get install -y python3 python3-venv python3-pip

python3 -m venv $HOME/base_venv
source $HOME/base_venv/bin/activate

xargs -r python -m pip install --upgrade < "$CONF_DIR/python_packages.txt"

exec bash --rcfile <(echo "source \"$HOME/base_venv/bin/activate\"; exec bash")
