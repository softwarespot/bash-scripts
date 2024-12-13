#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

# URL: https://www.techradar.com/how-to/how-to-speed-up-ubuntu-1804
sudo apt-get clean
sudo apt-get autoremove --purge
