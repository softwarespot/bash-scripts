#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

kubectl get pods | grep Terminating | awk '{print $1}' | xargs kubectl delete pod --force
