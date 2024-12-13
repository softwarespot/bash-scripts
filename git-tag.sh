#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

# Check if there are any uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Error: There are uncommitted changes in the repository."
    exit 1
fi

VERSION="$1"

# Check if the version number is provided
if [[ -z "$VERSION" ]]; then
    echo "Error: Version number is missing."
    exit 1
fi

if git tag -a "$VERSION" -m "Created release as v$VERSION"; then
    git push && git push --tags
else
    echo "Error: Failed to create the tag."
    exit 1
fi
