#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

# Retrieve information about the latest Git tag
LATEST_TAG=$(git describe --tags)
echo "$LATEST_TAG"
