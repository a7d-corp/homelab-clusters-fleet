# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Add `CiliumBGPPeeringPolicy` for control-plane nodes.
- Add Ingress to expose Kubernetes API via `ingress-nginx`.
- Add nginx port mapping for 6443 through to `default/kubernetes` svc.
- Add proxmox-csi.
- Remove `talos-cloud-controller-manager` and add `proxmox-cloud-controller-manager`.
- Re-add `kubelet-csr-approver`.
- Add zone and region topology labels to nodes.
- Add manual renovate upstream repo tags for CAPI controller versions.
- Manage `siderolink` secret in bootstrap and MC clusters.

### Changed

- Scale up MC to 3 masters.
- Enable ssl-passthrough for `ingress-nginx`.
- Align machine names across all resources.
- Use variables across Qemu/Server/ServerClass resources.
- Explicitly set Qemu machine type to avoid Proxmox iPXE UUID bug.
- Rename 'master' to 'controlplane'.
- Add Talos cloud-controller-manager and remove kubelet-csr-approver.
- Rework initial cluster bootstrapping to install talos-ccm early.
- Allow Flux to run on controlplane+uninitialized nodes (required for bootstrapping).
- Make kyverno env-vars clusterpolicy more generic.
- Update MC kustomizations.
- Update MC Flux version to 2.2.3.
- Update all HelmReleases to v2beta2.
- Stop creating spare nodes.
- Use talos-ccm and proxmox-ccm together.
- Rework early CAPI cluster bootstrapping.
- Fully rework early MC cluster bootstrapping.
- Deploy CCM secrets before installing CCMs.
- Ensure QEMU VM names match node names.
- Use a hash suffix to ensure machine templates have unique names to facilitate upgrades.
- Pin external-dns to last known working version with DNSEndpoint CRD.
- Update HelmReleases to v2.
- Update HelmRepository manifests to v1.
- Use Talos image factory to set install image instead of specifying extensions directly.

### Fixed

- Attempt to finally correct machine names and ordering.
- Add fake name field to flux toleration patch.
- Correct proxmox-ccm and proxmox-csi manifests.
- Fix remote installation of both CCMs.
- Create Proxxmox CSI storageclass.

## [1.0.0] - 2024-01-03

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
- Use `proxmox-operator` to provision MC machines.
- Add `kyverno` in standalone mode.
- Add ClusterPolicy to mutate `proxmox-operator` with proxy env vars.

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
- Rework controller config deployment.
- Rework qemu resources and add static MAC addresses.
- Reduce repetitive UUIDs by using cluster vars intead.
- Update workflows now the `hub` cli is gone.

### Removed

- Drop flux CRD installation to remote cluster.
- Remove misc CR kustomization.

[Unreleased]: https://github.com/a7d-corp/homelab-clusters-fleet/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/a7d-corp/homelab-clusters-fleet/releases/tag/v1.0.0
