#!/bin/bash

echo -e "\n[INF] checking vault status"

vault status > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
   echo "[ERR]: vault is not accessible"
   exit
else
   echo "[INF]: vault is unsealed, continuing"
fi

TOKEN=$(rbw get "Vault token")

export VAULT_TOKEN=${TOKEN}
echo "export VAULT_TOKEN=${TOKEN}"
echo "export VAULT_TOKEN=${TOKEN}" | xclip -selection clipboard
