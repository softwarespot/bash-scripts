#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

# Idea from URL: https://jlelse.blog/dev/script-go-deps-updates

ROOT_DIR=$(pwd)

update_deps() {
    ABS_DIR=$1

    ABS_GO_MOD="$ABS_DIR/go.mod"
    ABS_GO_SUM="$ABS_DIR/go.sum"

    if [[ ! -f $ABS_GO_MOD ]]; then
        echo "Skipping, as \"$ABS_DIR\" does not contain a \"go.mod\" file"
        echo ""
        return
    fi

    GIT_REPO=$(git config --get remote.origin.url 2>/dev/null)
    echo "Directory: $ABS_DIR, Repository URL: $GIT_REPO"
    git pull --rebase --prune &>/dev/null

    UPDATES=$(go list -f '{{if (and (not .Indirect) .Update)}}{{.Path}}{{end}}' -u -m all)

    if [[ -n "$UPDATES" ]]; then
        echo "$UPDATES"
        echo ""
        read -p "Would you like to update the dependencies for \"$ABS_DIR\"? " -n 1 -r
        echo ""

        # Taken from URL: https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for UPDATE in $UPDATES
            do
                echo ""
                echo "Updating $UPDATE"
                go get "$UPDATE@latest"
                go mod tidy
            done

            git add "$ABS_GO_MOD"
            git add "$ABS_GO_SUM"
            git commit -m "(chore) Updated deps" -n
            git pull --rebase --prune
            git push
        fi
    else
        echo "Skipping, as \"$ABS_DIR\" has no dependencies to be updated"
    fi
    echo ""
}

for DIR in $(find . -name "go.mod" | grep -v "charts"); do
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
