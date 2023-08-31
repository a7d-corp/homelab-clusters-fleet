# Adding a cluster

Process (high level):

* Create all necessary configs in this repo.
* Create instances with Terraform (e.g. https://github.com/a7d-corp/homelab-k8s-cluster-room101-a7d-mc).
* Create DNS bootstrap A record for K8S API FQDN pointing to one (or several) master IPs.
* Bootstrap the cluster with Sidero.
* Delete the DNS bootstrap A record after `external-dns` + `Ingress` allow BGP routed access to the K8S API.

## Pre-setup

### Cluster config

* Add a new dir under `/kubernetes/clusters`.
* Create cluster secrets with `talosctl gen secrets`.
* Create `sops` encrypted secret named `talos-secrets.yaml` from previously generated secrets.
* Create `cluster-vars-configmap.yaml` with required variables.
* Create serverclasses for controlplane and workers.
* Generate certificates for MC `kubeconfig` and `talosconfig` at `/kubernetes/pki`.

### BGP config

* Create BGP neighbours for every IP in cluster subnet to allow Cilium to announce routes (see `/hack/` dir).
