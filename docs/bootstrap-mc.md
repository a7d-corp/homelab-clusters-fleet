# Bootstrap cluster

The bootstrap cluster is used to bootstrap Flux into the management cluster. Flux is installed by hand in the bootstrap cluster (single node KIND cluster) which then creates a management cluster with CAPMOX on VMs. Flux deploys a CNI into the MC and then deploys Flux (which is automatically configured to start reconciling the MC directory in `clusters`). The deployed Flux then starts managing itself (as well as the rest of the cluster) and the bootstrap machine can be destroyed as it is no longer required (once pivoting has happened).

## Proxmox VM creation

VMs are created by [cluster-api-provider-proxmox]](https://github.com/ionos-cloud/cluster-api-provider-proxmox) using [these manifests](/kubernetes/clusters/resources/).

## Bootstrap cluster configuration

See the [recreate-mc.sh](/hack/recreate-mc.sh) script.