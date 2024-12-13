#!/bin/bash

# Linted using https://www.shellcheck.net

set -e

# Retrieve information about the latest git tag
LATEST_TAG=$(git describe --tags)
echo "$LATEST_TAG"
