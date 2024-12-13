#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

ROOT_DIR=$(pwd)

check_no_nvm() {
    ABS_DIR=$1

    # if [[ ! -d ".git" ]]; then
    #     echo "Skipping, as \"$ABS_DIR\" does not contain a \".git\" directory"
    #     echo ""
    #     return
    # fi

    ABS_PKG_JSON="$ABS_DIR/package.json"

    if [[ ! -f $ABS_PKG_JSON ]]; then
        # echo "Skipping, as \"$ABS_DIR\" does not contain a \"package.json\" file"
        # echo ""
        return
    fi

    git pull --rebase --prune

    ABS_NVM_RC="$ABS_DIR/.nvmrc"

    if [[ ! -f $ABS_NVM_RC ]]; then
        GIT_REPO=$(git config --get remote.origin.url 2>/dev/null)
        echo "\"$ABS_DIR\" does not contain a \".nvmrc\" file. See repository URL: $GIT_REPO"
    fi
}

for DIR in $(find . -name 'package.json' | grep -v 'node_modules' | grep -v 'bower_components' ); do
    REL_DIR=$(dirname "$DIR")
    ABS_DIR=$(realpath "$REL_DIR")
    # echo "$ABS_DIR"

    cd "$ABS_DIR" || exit 1
    check_no_nvm "$ABS_DIR"
    cd "$ROOT_DIR" > /dev/null || exit 2
done
