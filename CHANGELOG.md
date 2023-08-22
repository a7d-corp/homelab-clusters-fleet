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
- Bump Cilium to 1.14.0 and add config for running on Talos.
- Move cluster kustomizations to remote cluster namespace.
- Drop flux CRD installation to remote cluster.
- Disable preflight mode for Cilium.
- Tidy up room101-a7d-mc cluster dir to match bootstrap cluster.
- Completely rework apps dir.
- Rename flux sync release to flux--system.
- Add `cluster-api-operator`.
- Add bootstrap kubeconfig to bootstrap cluster.
- Split custom resources out from controllers.

[Unreleased]: https://github.com/a7d-corp/homelab-clusters-fleet/tree/main

