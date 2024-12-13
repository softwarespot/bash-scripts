#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

# Ensure nvm is available
readonly NVM_DIR="$HOME/.nvm"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    printf "nvm is not installed correctly. Please install nvm and try again.\n" >&2
    exit 1
fi

# shellcheck disable=SC1091
source "$NVM_DIR/nvm.sh"

ROOT_DIR=$(pwd)

NCU_TARGET=minor
ARG_NCU_TARGET=$1

if [[ -n $ARG_NCU_TARGET ]]; then
    NCU_TARGET="$ARG_NCU_TARGET"
fi

update_deps() {
    ABS_DIR=$1

    # if [[ ! -d ".git" ]]; then
    #     echo "Skipping, as \"$ABS_DIR\" does not contain a \".git\" directory"
    #     echo ""
    #     return
    # fi

    ABS_PKG_JSON="$ABS_DIR/package.json"
    ABS_PKG__LOCK_JSON="$ABS_DIR/package-lock.json"
    if [[ ! -f $ABS_PKG_JSON ]]; then
        echo "Skipping, as \"$ABS_DIR\" does not contain a \"package.json\" file"
        echo ""
        return
    fi

    GIT_REPO=$(git config --get remote.origin.url 2>/dev/null)
    echo "Directory: $ABS_DIR, Repository URL: $GIT_REPO"
    git pull --rebase --prune &>/dev/null

    ABS_NVM_RC="$ABS_DIR/.nvmrc"
    if [[ ! -f $ABS_NVM_RC ]]; then
        # echo "Using/installing stable Node.js"
        # nvm install stable

        echo "Skipping, as \"$ABS_DIR\" does not contain a \".nvmrc\" file"
        echo ""
        return
    fi

    echo "Using/installing Node.js defined in the \".nvmrc\""
    nvm install
    # nvm use

    if ! command -v "ncu" > /dev/null; then
        echo ""
        echo "Installing \"ncu\" globally, as it's currently missing"
        npm install -g npm-check-updates
        echo ""
    fi

    # ncu --errorLevel 2
    ncu --target "$NCU_TARGET" --errorLevel 2
    NCU_ERR_CODE=$?
    if [[ $NCU_ERR_CODE -ne 0 ]]; then
        read -p "Would you like to update the dependencies for \"$ABS_DIR\"? " -n 1 -r
        echo ""

        # Taken from URL: https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # ncu --errorLevel 2 --upgrade
            ncu --target "$NCU_TARGET" --errorLevel 2 --upgrade
            npm install --force
            git add "$ABS_PKG_JSON"
            if [[ -f $ABS_PKG__LOCK_JSON ]]; then
                git add "$ABS_PKG__LOCK_JSON"
            fi
            git commit -m "(chore) Updated deps" -n
            git pull --rebase --prune
            git push
        fi
    else
        echo "Skipping, as \"$ABS_DIR\" has no dependencies to be updated"
    fi
    echo ""
}

for DIR in $(find . -name '.nvmrc' | grep -v 'node_modules' | grep -v 'bower_components' ); do
    REL_DIR=$(dirname "$DIR")

    # Skip the following directories, as they can't be updated
    SKIP_DIRS=(
    )

    SKIP=false
    for SKIP_DIR in "${SKIP_DIRS[@]}"; do
        if [[ $REL_DIR = "$SKIP_DIR" ]]; then
            SKIP=true
            break
        fi
    done

    if [[ $SKIP = true ]]; then
        continue
    fi

    ABS_DIR=$(realpath "$REL_DIR")

    cd "$ABS_DIR" || exit 1
    update_deps "$ABS_DIR"
    cd "$ROOT_DIR" > /dev/null || exit 2
done
