#!/bin/bash

# Linted using https://www.shellcheck.net

# Ensure nvm is available
readonly NVM_DIR="$HOME/.nvm"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    printf "nvm is not installed correctly. Please install nvm and try again.\n" >&2
    exit 1
fi

# shellcheck disable=SC1091
source "$NVM_DIR/nvm.sh"

CURR_DIR=$(dirname "$0")

# See URL: https://nodejs.org/en/about/previous-releases
nvm use 16.20.2

if [[ $1 = "es5" ]]; then
    echo "Using $CURR_DIR/.es5_prettierrc"
    npx prettier@latest --write . --config "$CURR_DIR/.es5_prettierrc"
else
    echo "Using $CURR_DIR/.prettierrc"
    npx prettier@latest --write . --config "$CURR_DIR/.prettierrc"
fi
