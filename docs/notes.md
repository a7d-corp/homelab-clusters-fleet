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

## Sidero + ClusterAPI

Talos version to use is configured via the `cluster-api-operator` `CoreProvider`. Usually patched by kustomization:

```
    - patch: |
        - op: add
          path: /spec
          value:
            version: v1.5.5
      target:
        kind: CoreProvider
        name: cluster-api
```

Kubernetes version to deploy is configured per cluster via substitution vars:

```
kubernetes/clusters/room101-a7d-mc/cluster-vars-configmap.yaml
```
