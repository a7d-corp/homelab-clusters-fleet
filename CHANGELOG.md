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
- Add server manifests for MC cluster workers
- Add hostnames to all `room101-a7d-mc` `Servers`.
- Add `kubelet-csr-approver`.
- Add Environment and configure all serverclasses to consume it.

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
- Rename and tidy all bootstrap kustomizations.
- Rename `infrastructure` dir to `workloads`.
- Correct missing apiversion from cluster resources.
- Update capi provider version and correct installation of infra provider.
- Update CAPI provider manifests to v1alpha2.
- Correct server-side-apply method for Server resources.
- Update k8s 1.27.4 > 1.28.3.
- Update sidero infraprovider 1.5.2 > 1.5.5.
- Update MC talos version v1.4.7 > v1.5.5.
- Switch `/addons` dir to bases pattern to easier differentiate between cluster types.
- Switch `/workloads/controllers` dir to bases pattern to easier differentiate between cluster types.
- Tidy dex infra and only expose ingresses internally.
- Correct oauth2-proxy secret config
- Migrate misc cluster configs to separate dir.
- Recreate accidentally-exposed secrets.
- Set IP for nginx LB service and sidero DNSEndpoint.

### Removed

- Drop flux CRD installation to remote cluster.
- Remove misc CR kustomization.

[Unreleased]: https://github.com/a7d-corp/homelab-clusters-fleet/tree/main

