#!/bin/bash

KEY=$(rbw get "SOPS AGE key homelab-clusters-fleet")

export SOPS_AGE_KEY=${KEY}
echo "export SOPS_AGE_KEY=${KEY}"
echo "export SOPS_AGE_KEY=${KEY}" | xclip -selection clipboard
