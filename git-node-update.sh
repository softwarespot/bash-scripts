#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

SCRIPT_NAME="git-node-update.sh"

# Ensure nvm is available
NVM_DIR="$HOME/.nvm"

# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

ROOT_DIR=$(pwd)

NODE_VERSION=$1

if [[ -z $NODE_VERSION ]]; then
    echo "Usage: $SCRIPT_NAME <VERSION>"
    exit 1
fi

update_node() {
    ABS_DIR=$1

    # if [[ ! -d ".git" ]]; then
    #     echo "Skipping, as \"$ABS_DIR\" does not contain a \".git\" directory"
    #     echo ""
    #     return
    # fi

    GIT_REPO=$(git config --get remote.origin.url 2>/dev/null)
    echo "Directory: $ABS_DIR, Repository URL: $GIT_REPO"
    git pull --rebase --prune &>/dev/null

    ABS_NVM_RC="$ABS_DIR/.nvmrc"
    if [[ -f $ABS_NVM_RC ]]; then
        CURR_NVM_VERSION=$(cat "$ABS_NVM_RC")
        if [[ $CURR_NVM_VERSION != "$NODE_VERSION" ]]; then
            read -p "Would you like to update the Node.js version in the \".nvmrc\" file from $CURR_NVM_VERSION to $NODE_VERSION " -n 1 -r
            echo ""

            # Taken from URL: https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "$NODE_VERSION" > "$ABS_NVM_RC"
                nvm install
                git add "$ABS_NVM_RC"
                git commit -m "(chore) Updated the Node.js version in the .nvmrc file to $NODE_VERSION" -n
                git pull --rebase --prune
                git push
                echo "Updated the Node.js version in the \"$ABS_NVM_RC\" file to $NODE_VERSION"
            fi
        else
            echo "Skipping, as the current Node.js version in the \".nvmrc\" file is $CURR_NVM_VERSION"
        fi
    else
        echo "Skipping, as \"$ABS_DIR\" does not contain a \".nvmrc\" file"
    fi

    ABS_PKG_JSON="$ABS_DIR/package.json"
    CURR_ENGINES_VERSION=$(jq '.engines.node' -r "$ABS_PKG_JSON" 2>/dev/null)
    NEXT_ENGINES_VERSION=">=$NODE_VERSION"
    if [[ "$CURR_ENGINES_VERSION" != "" && "$CURR_ENGINES_VERSION" != "null" ]]; then
        if [[ "$CURR_ENGINES_VERSION" != "$NEXT_ENGINES_VERSION" ]]; then
            read -p "Would you like to update the Node.js engines version in the \"package.json\" file from \"$CURR_ENGINES_VERSION\" to \"$NEXT_ENGINES_VERSION\"" -n 1 -r
            echo ""

            # Taken from URL: https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                PKG_DATA=$(jq --arg engVer "$NEXT_ENGINES_VERSION" '.engines.node = $engVer' "$ABS_PKG_JSON")
                echo "${PKG_DATA}" > "$ABS_PKG_JSON"
                git add "$ABS_PKG_JSON"
                git commit -m "(chore) Updated the Node.js version in the package.json file to $NEXT_ENGINES_VERSION" -n
                git pull --rebase --prune
                git push
                echo "Updated the Node.js version in the \"$ABS_PKG_JSON\" file to \"$NEXT_ENGINES_VERSION\""
            fi
        else
            echo "Skipping, as the current Node.js engines version in the \"package.json\" file is \"$NEXT_ENGINES_VERSION\""
        fi
    else
        echo "Skipping, as \"$ABS_PKG_JSON\" does not contain an engines property"
    fi

    ABS_DKRFILE="$ABS_DIR/Dockerfile"
    if [[ -f $ABS_DKRFILE ]]; then
        CURR_DOCKER_VERSION=$(head -n 1 "$ABS_DKRFILE")
        NEXT_DOCKER_VERSION="FROM node:$NODE_VERSION"
        if [[ "$CURR_DOCKER_VERSION" != "$NEXT_DOCKER_VERSION" ]]; then
            read -p "Would you like to update the Node.js in the \"Dockerfile\" file from \"$CURR_DOCKER_VERSION\" to \"$NEXT_DOCKER_VERSION\"" -n 1 -r
            echo ""

            # Taken from URL: https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sed -i "1 c\FROM node:$NODE_VERSION" "$ABS_DKRFILE"
                git add "$ABS_DKRFILE"
                git commit -m "(chore) Updated the Node.js version in Dockerfile to $NEXT_DOCKER_VERSION" -n
                git pull --rebase --prune
                git push
                echo "Updated the Node.js version in the \"$ABS_DKRFILE\" file to \"$NEXT_DOCKER_VERSION\""
            fi
        else
            echo "Skipping, as the current Node.js version in the \"Dockerfile\" file is \"$NEXT_DOCKER_VERSION\""
        fi
    else
        echo "Skipping, as \"$ABS_DIR\" does not contain a \"Dockerfile\" file"
    fi

    echo ""
}

for DIR in $(find . -name '.nvmrc' | grep -v 'node_modules' | grep -v 'bower_components' ); do
    REL_DIR=$(dirname "$DIR")
    ABS_DIR=$(realpath "$REL_DIR")
    # echo "$ABS_DIR"

    cd "$ABS_DIR" || exit 1
    update_node "$ABS_DIR"
    cd "$ROOT_DIR" > /dev/null || exit 2
done
