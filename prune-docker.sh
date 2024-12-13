#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

docker image prune -f --all --filter until=1h
docker system prune -f --all --filter until=1h
docker container prune -f --filter until=1h
