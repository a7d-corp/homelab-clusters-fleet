# Gitops + ClusterAPI = Kubernetes

## Repo structure

Directories are listed roughly in the order in which they are applied.

`/clusters/`

Each subdir represents everything required to create and run a Kubernetes cluster - these are the base dirs which are reconciled by Flux running in each cluster.

`/clusters/bootstrap/`

Ephemeral cluster created in order to bootstrap the management cluster. Usually a single-node Talos cluster running in Docker which is removed once the MC becomes self-managing. See [bootstrap-mc.md](bootstrap-mc.md).

`/workloads/cni/`

All resources required to install and manage a CNI in a cluster (currently Cilium running in strict mode)

`/workloads/controllers/`

Controllers defined here are required for each cluster, depending on whether the cluster is a management or workload cluster.


`/workloads/flux/`

Configs to install and manage Flux and all core components in a cluster; all clusters manage themselves once they have been bootstrapped.

`/workloads/addons/`

Additional applications which are required to support a cluster.

`/kubernetes/resources/`

Template manifests for CAPI components used by Sidero to create a cluster.

`/kubernetes/clusters/`

Subdirs contain manifests for various Sidero-specific components in order to customise the cluster deployment. Kubernetes nodes are configured at this level (networking, low-level Kubernetes settings such as kubelet args etc).

`/apps/`

Subdirs contain config for optional applications running in clusters.

`/apps/base/`

Shared app config between all clusters which is inherited and extended by clusters running each app.

`/apps/$clustername/`

Cluster-specific config for apps in each cluster.

`/hack/`

Contains various supporting scripts and information used to create clusters (not reconciled by Flux).

## Notes

- Certificate authorities for Kubernetes and Talos are generated ahead of cluster creation (see [/hack/pki/](/hack/pki/README.md) for more info).
- Networking has some specific configuration for each cluster (see [networking.md](networking.md)).
- Clusters can create `Loadbalancer` services. This is handled by Cilium which advertises the IP via BGP to Opnsense (see [this configmap](/clusters/room101-a7d-mc/cilium-configs/bgp-config-cm.yaml) as an example)
