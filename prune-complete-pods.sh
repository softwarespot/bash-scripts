#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

kubectl get pods | grep Completed | awk '{print $1}' | xargs kubectl delete pod
