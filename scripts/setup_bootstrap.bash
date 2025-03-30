#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CONF_DIR="$SCRIPT_DIR/conf"

sudo apt-get update && sudo apt-get install -y python3 python3-venv python3-pip

python3 -m venv temp_venv
source temp_venv/bin/activate

xargs -r python -m pip install --upgrade < "$CONF_DIR/python_packages.txt"
python3 -m pip install -e python_bootstrap

exec bash --rcfile <(echo "source \"temp_venv/bin/activate\"; exec bash")
