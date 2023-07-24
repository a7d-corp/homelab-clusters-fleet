# homelab-clusters-fleet

## Repo structure

`clusters/`:

The clusters dir is the base directory which is reconciled by Flux. Here we use the `dependsOn` value to ensure that the resources are installed in a predictable order (CNI, controllers, config, apps).

`infrastructure/`:

The infrastructure dir contains the core tooling needed to create a basic working cluster in order to be able to deploy apps.

`apps/`:

The apps dir customises the cluster for its intended purpose. The dir has a `base` directory which specifies default values for apps which are then overridden (where necessary) in the cluster-specific directory.
