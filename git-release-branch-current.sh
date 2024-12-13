#!/bin/bash

# Linted using https://www.shellcheck.net

set -e

# Retrieve the latest remote branch name that starts with "rel_"
LATEST_BRANDH=$(git for-each-ref --sort=-committerdate refs/remotes/origin | grep rel_ | head -n 1 | cut -d"/" -f4)
echo "$LATEST_BRANDH"
