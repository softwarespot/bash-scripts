#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

# Script for deleting evicted pods from cluster.
# Use without parameters for current namespaces or supply --all-namespaces
# to evict from all active namespaces.

if [[ "$1" == "--all-namespaces" ]]; then
    for KB_NAMESPACE in $(kubectl get namespaces | grep Active | awk '{print $1}'); do
        echo "Deleting from namespace ${KB_NAMESPACE}..."
        for KB_POD in $(kubectl get pods -n "${KB_NAMESPACE}" | grep Evicted | awk '{print $1}'); do
            echo "Will delete ${KB_POD}..."
            kubectl delete pods "${KB_POD}" -n "${KB_NAMESPACE}"
        done
    done
elif [[ "$1" == "" ]]; then
    for KB_POD in $(kubectl get pods | grep Evicted | awk '{print $1}'); do
        echo "Will delete ${KB_POD}..."
        kubectl delete pods "${KB_POD}"
    done
else
    echo "Usage: $0 [--all-namespaces]"
    exit 1
fi
