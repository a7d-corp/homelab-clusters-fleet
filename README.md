# homelab-clusters-fleet

## Repo structure

`clusters/`:

The clusters dir is the base directory which is reconciled by Flux. Here we use the `dependsOn` value to ensure that the resources are installed in a predictable order (CNI, controllers, config, apps).

`workloads/`:

The workloads dir contains the core tooling needed to create a basic working cluster in order to be able to deploy apps.

`apps/`:

The apps dir customises the cluster for its intended purpose. The dir has a `base` directory which specifies default values for apps which are then overridden (where necessary) in the cluster-specific directory.

## Clusters

Cluster definitions live under the `clusters` directory.

### `bootstrap`

The bootstrap cluster is used to bootstrap Flux into the management cluster. Flux is installed by hand in the bootstrap cluster (single node Talos cluster running Sidero components) once the CAPI MC has been creatd. It first deploys a CNI into the MC, creates the required Flux config and then deploys Flux (which is automatically configured to start reconciling the MC directory in `clusters`). The deployed Flux then starts managing itself (as well as the rest of the cluster) and the bootstrap machine can be destroyed as it is no longer required.

### `room101-a7d-mc`

CAPI MC deployed by Sidero.
