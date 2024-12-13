#!/bin/bash

# Linted using https://www.shellcheck.net

kubectl get pods | grep Error | awk '{print $1}' | xargs kubectl delete pod
