#!/bin/bash

echo "Configuring Git... " #| tee -a $LOGFILE

# Check if user.name and user.email are already set in git config
name_set=$(git config --global user.name)
email_set=$(git config --global user.email)

# If user.name is not set, prompt for it and set it
if [ -z "$name_set" ]; then
    read -r -p "Enter your name: " name
    git config --global user.name "$name"
else
    echo "Git user.name is already set to '$name_set'"
fi

# If user.email is not set, prompt for it and set it
if [ -z "$email_set" ]; then
    read -r -p "Enter your email: " email
    git config --global user.email "$email"
else
    echo "Git user.email is already set to '$email_set'"
fi

git config --global init.templatedir '~/.git_template'
git config --global pull.rebase false

echo "Done!" #| tee -a $LOGFILE
