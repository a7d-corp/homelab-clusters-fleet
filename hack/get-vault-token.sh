#!/bin/bash

TOKEN=$(rbw get "Vault token")

export VAULT_TOKEN=${TOKEN}
echo "export VAULT_TOKEN=${TOKEN}"
echo "export VAULT_TOKEN=${TOKEN}" | xclip -selection clipboard
