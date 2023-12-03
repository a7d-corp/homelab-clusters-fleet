# Miscellanous notes

## Talos secrets

### Recreating cluster secrets (K8S PKI, Talos PKI etc)

#### Generate new secrets

```
talosctl gen secrets
mv secrets.yaml kubernetes/clusters/room101-a7d-mc/talos-secrets.yaml
sops -i -e kubernetes/clusters/room101-a7d-mc/talos-secrets.yaml
```

#### Generate new kubeconfig & talosconfig

See [PKI notes](/hack/pki/README.md).

Copy the new kubeconfig to the correct location (e.g. `clusters/bootstrap/cluster-prereqs/room101-a7d-mc-kubeconfig.yaml`).

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

Talos and Kubernetes versions to deploy are configured per cluster via substitution vars:

```
grep -E 'K8S_VERSION|TALOS_VERSION' kubernetes/clusters/room101-a7d-mc/cluster-vars-configmap.yaml
  K8S_VERSION: "1.28.3"
  TALOS_VERSION: "v1.5.5"
```

