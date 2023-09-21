# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial addition of base structure.
- Initial addition of config for `room101-a7d-mc` cluster.
- Initial addition of bootstrap cluster to remotely bootstrap `room101-a7d-mc`cluster.
- Deploy flux CRDs to management cluster.
- Add kubeconfig to Cilium HelmRelease for remote deployment.
- Deploy Cilium BGP config to MC.
- Add `cluster-api-operator`.
- Add bootstrap kubeconfig to bootstrap cluster.
- Add `opsense-add-bgp-neighbours.sh` to `/hacks/`.
- Add PKI details.
- Add Sidero resources.
- Add config and resources to create a cluster.
- Enable kubeprism.
- Set static IPs for all masters.
- Install CAPI operator and cert-manager in bootstrap cluster with Flux.

### Changed

- Bump Cilium to 1.14.0 and add config for running on Talos.
- Move cluster kustomizations to remote cluster namespace.
- Tidy up room101-a7d-mc cluster dir to match bootstrap cluster.
- Disable preflight mode for Cilium.
- Completely rework apps dir.
- Rename flux sync release to flux--system.
- Split custom resources out from controllers.
- Install cert-manager before other controllers.
- Install CAPI operator with raw yamls rather than helm.
- Patch `capi-operator-system` namespace to pass PSS.
- Split up infrastructure dir to reflect usage.
- Install capi providers after capi-operator is running.

### Removed

- Drop flux CRD installation to remote cluster.

[Unreleased]: https://github.com/a7d-corp/homelab-clusters-fleet/tree/main

