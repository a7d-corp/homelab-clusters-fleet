# Adding a cluster

## Cluster config

* Add a new dir under `kubernetes/clusters`.
* Create cluster secrets with `talosctl gen secrets`.
* Create `sops` encrypted secret named `talos-secrets.yaml` from previously generated secrets.
* Create `cluster-vars-configmap.yaml` with required variables.
* Create serverclasses for controlplane and workers.
* Generate certificates for MC `kubeconfig` and `talosconfig` at `kubernetes/pki`.
* 
