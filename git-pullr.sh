#!/bin/bash

# Linted using https://www.shellcheck.net

for REL_DIR in */ ; do
    ABS_DIR=$(realpath "$REL_DIR")

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
