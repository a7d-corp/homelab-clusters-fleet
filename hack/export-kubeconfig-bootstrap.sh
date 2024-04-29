#!/bin/bash

GIT_BASE=$(git rev-parse --show-toplevel)

echo "export KUBECONFIG=${GIT_BASE}/tmp/bootstrap.kubeconfig"
echo "export KUBECONFIG=${GIT_BASE}/tmp/bootstrap.kubeconfig" | xclip -selection clipboard
