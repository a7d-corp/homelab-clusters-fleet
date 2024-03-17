#!/bin/bash

KEY=$(rbw get "SOPS AGE key homelab-clusters-fleet")

echo "export SOPS_AGE_KEY=$KEY"
