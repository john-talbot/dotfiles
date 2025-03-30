#!/bin/sh

set -e  # Exit on any failure

GIT_URL="https://github.com/john-talbot/dotfiles.git"
LOG_DIR="logs"
TEMP_DIR="temp"
VENV_DIR="$TEMP_DIR/venv"

# Clone dotfiles repo with submodules
cd "$HOME"
git clone --recurse-submodules "$GIT_URL" "$HOME/.dotfiles" 

# Bootstrap
cd "$HOME/.dotfiles/scripts"
mkdir -p "$TEMP_DIR" "$LOG_DIR"
python3 -m venv "$VENV_DIR"
. "$VENV_DIR/bin/activate"

pip install -e python_bootstrap
bootstrap --temp "$TEMP_DIR" --log "$LOG_DIR"

rm -rf "$TEMP_DIR"
