# Bootstrap cluster

The bootstrap cluster is used to bootstrap Flux into the management cluster. Flux is installed by hand in the bootstrap cluster (sing  le node Talos cluster running Sidero components) which then creates a management cluster with Sidero on VMs. Flux deploys a CNI into the MC, creates the required Flux config and then deploys Flux (which is automatically configured to start reconciling the MC directory in `clusters`). The deployed Flux then starts managing itself (as well as the rest of the cluster) and the bootstrap machine can be destroyed as it is no longer required.

## Cluster creation

- VMs should be created first (will bootloop until Sidero is running).
- Create A record `sidero.room101-a7d-mc.lab.a7d.dev` pointing to bootstrap node.

## Proxmox VM creation

Use Terraform repo (e.g. [this one for the MC](https://github.com/a7d-corp/homelab-k8s-cluster-room101-a7d-mc/)) to create the VMs. Ensure they are all started and bootlooping.

## Initial DNS configuration

Kubernetes API access needs to be configured before cluster creation; once the cluster is up it can be managed by `external-dns`. Create 3 DNS records for the Kubernetes API FQDN to point at the control-plane node IPs (see [networking.md](networking.md)).

Create A record `sidero.room101-a7d-mc.lab.a7d.dev` pointing to bootstrap node.

## Bootstrap cluster configuration

### Local Flux

- Create required namespaces:

```
k create ns cluster-room101-a7d-mc
k create ns flux-system
```

Create secrets required for Flux to decrypt SOPs-encrypted secrets:

```
vault kv get -mount=cluster-room101-a7d-mc -field=data sops-age \
	| base64 -d | kubectl apply -n flux-system -f -
vault kv get -mount=cluster-room101-a7d-mc -field=data sops-age \
	| base64 -d | kubectl apply -n cluster-room101-a7d-mc -f -
```

Create secret required for Flux to authenticate against Github:

```
k create secret generic flux-system -n flux-system \
	--from-literal=identity="$(vault kv get -mount=cluster-room101-a7d-mc -field=identity flux-bootstrap-deploy-key | base64 -d)" \
	--from-literal=identity.pub="$(vault kv get -mount=cluster-room101-a7d-mc -field=identity.pub flux-bootstrap-deploy-key | base64 -d)" \
	--from-literal=known_hosts="$(vault kv get -mount=cluster-room101-a7d-mc -field=known_hosts flux-bootstrap-deploy-key | base64 -d)"
```

Bootstrap Flux:

```
flux bootstrap github --owner a7d-corp --repository homelab-clusters-fleet \
	--branch main --path clusters/bootstrap --secret-name flux-system
```

### Manual intervention

Bootstrap cluster initialisation will stop before creating [Talos resources](/clusters/bootstrap/20-talos-cluster.yaml) as they are suspended. Check all `Servers` are registered with the bootstrap cluster before proceeding.

When ready, run the following and commit the changes:

```
sed -i 's/suspend: true/suspend: false/g' clusters/bootstrap/20-talos-cluster.yaml && \
    git add clusters/bootstrap/20-talos-cluster.yaml && \
    git commit -m "resume reconciliation of bootstrap cluster Talos resources" && \
    git push
```

## Post setup

- Remove DNS records created for Kubernetes API FQDN.
- Re-point `sidero.room101-a7d-mc.lab.a7d.dev` to new MC cluster.
