#!/bin/bash

set -e

echo "Configuring Git... " | tee -a $LOGFILE

echo -e "\tEnter your name: \c"
read name

echo -e "\tEnter your email: \c"
read email

git config --global user.name $name
git config --global user.email $email
git config --global init.templatedir '~/.git_template'

echo "Done!" | tee -a $LOGFILE
