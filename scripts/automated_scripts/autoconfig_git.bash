#!/bin/bash

echo "Configuring Git... " | tee -a $LOGFILE

# Function to get git config value or return an empty string if not set
get_git_config() {
    git config --global "$1" || echo ""
}

# Function to strip quotes from the beginning and end of a string
strip_quotes() {
  echo "$1" | sed -e 's/^["'"'"']//g' -e 's/["'"'"']$//g'
}

# Initialize variables
name=""
email=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --git-name)
            name=$(strip_quotes "$2")
            shift 2
            ;;
        --git-email)
            email=$(strip_quotes "$2")
            shift 2
            ;;
        *)
            echo "Usage: $0 [--git-name name] [--git-email email]" >&2
            exit 1
            ;;
    esac
done

# Check if user.name and user.email are already set in git config
name_set=$(get_git_config "user.name")
email_set=$(get_git_config "user.email")

# If user.name is not set, prompt for it or use the provided argument
if [[ -z "$name_set" ]]; then
    if [[ -z "$name" ]]; then
        read -r -p "Enter your name: " name
    fi
    git config --global user.name "$(strip_quotes "$name")"
else
    echo "Git user.name is already set to '$name_set'" | tee -a $LOGFILE
fi

# If user.email is not set, prompt for it or use the provided argument
if [[ -z "$email_set" ]]; then
    if [[ -z "$email" ]]; then
        read -r -p "Enter your email: " email
    fi
    git config --global user.email "$(strip_quotes "$email")"
else
    echo "Git user.email is already set to '$email_set'" | tee -a $LOGFILE
fi

git config --global init.templatedir '~/.git-template'
git config --global pull.rebase false

echo "Done!" | tee -a $LOGFILE
