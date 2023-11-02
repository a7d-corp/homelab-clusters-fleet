# Miscellanous notes

## `talos-cluster-secrets.yaml`

Override repo-level SOPs configuration to encrypt the secret:

```
sops --encrypted-regex="bundle" -e -i talos-secrets.yaml
```

Decrypt a SOPS-encrypted file:

```
export SOPS_AGE_KEY=$(vault kv get -mount=cluster-room101-a7d-mc -field=data sops-age-secret)
sops -d -i secret.yaml
```
