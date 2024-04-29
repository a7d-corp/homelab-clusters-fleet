#!/bin/bash

GIT_BASE=$(git rev-parse --show-toplevel)

echo "export KUBECONFIG=${GIT_BASE}/tmp/room101-a7d-mc.kubeconfig"
echo "export KUBECONFIG=${GIT_BASE}/tmp/room101-a7d-mc.kubeconfig" | xclip -selection clipboard
