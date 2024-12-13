#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

# Ensure nvm is available
NVM_DIR="$HOME/.nvm"

# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

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
