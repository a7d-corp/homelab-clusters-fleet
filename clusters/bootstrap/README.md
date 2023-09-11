# Bootstrap cluster

## Cluster creation

- VMs should be created first (will bootloop until Sidero is running).
- Create A record `sidero.room101-a7d-mc.lab.a7d.dev` pointing to bootstrap node.

## Bootstrap cluster configuration

### Local Flux

- Flux is bootstrapped manually using path `clusters/bootstrap`.

### Local cluster prereqs

- `cluster-room101-a7d-mc` cluster namespace is created.
- kubeconfig for `room101-a7d-mc` is created in cluster namespace.

### Local controllers

1. `cert-manager` (`local-controllers.yaml`, depends on local cluster prereqs)
2. `capi-operator` (`local-controllers.yaml`, depends on `cert-manager`)
3. controller CRs (`local-controllers.yaml`, depends on `capi-operator`)

### MC Sidero cluster

1. Creation of custom Sidero configurations (see `kubernetes/clusters/room101-a7d-mc`)
2. Creation of MC cluster via Sidero CRs

## Management cluster configuration

1. Creation of `cilium` namespace.
2. Creation of `cilium` BGP config.
3. Installation of `cilium`.
4. Installation of `flux` (which takes over managing all resources).

## Post-setup

- Re-point `sidero.room101-a7d-mc.lab.a7d.dev` to new MC cluster.
