#!/bin/bash

# Linted using https://www.shellcheck.net

kubectl get pods | grep Terminating | awk '{print $1}' | xargs kubectl delete pod --force
