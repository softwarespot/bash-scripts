#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

for DIR in */ ; do
    ABS_DIR=$(realpath "$DIR")
    # echo "$ABS_DIR"

    cd "$ABS_DIR" || exit 1
    if [[ -d ".git" ]]; then
        GIT_REPO=$(git config --get remote.origin.url 2>/dev/null)
        GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        echo "Directory: $ABS_DIR, Repository URL: $GIT_REPO, Branch: $GIT_BRANCH"
        git pull --rebase --prune
        echo ""
    fi
    cd - > /dev/null || exit 2
done
