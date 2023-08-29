# room101-a7d-mc cluster configuration

## `talos-cluster-secrets.yaml`

Override repo-level SOPs configuration to encrypt the secret:

```
sops --encrypted-regex="bundle" -e -i talos-cluster-secrets.yaml
```

Decrypt the file:

```
export SOPS_AGE_KEY=AGE-SECRET-KEY-1W6S4HT...
sops -d -i talos-cluster-secrets.yaml
```
