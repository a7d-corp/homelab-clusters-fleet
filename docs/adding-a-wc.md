# Adding a new WC

## Things to remember

### Networking

- Add BGP pool for VIPs to [Opnsense](https://opnsense.int.analbeard.com/ui/quagga/bgp/index)
- Ensure node IPs are added to Opnsense as BGP neighbours
- K8S API VIP is the last-but-one IP in the BGP pool
- NGINX VIP is the last IP in the BGP pool
- Add relevant DNS records to static mapping in blocky (temporarily)
- Add proxied domains to Haproxy config (if necessary)

#### Firewall rules

- 179/TCP from node subnet to firewall (BGP)
- 53/UDP from node subnet to internal DNS servers
- 123/UDP from node subnet to internal NTP servers
- 3128/TCP from node subnet to `austin` (squid proxy)
- 50000/TCP from LAN subnet to node subnet (Talos API)
- 6443/TCP from MC subnet to node subnet (K8S API)
- 8006/TCP from node subnet to proxmoxHosts alias (Proxmox API)

### Certificates

- Generate K8S and Talos certificates (see [/hack/pki](/hack/pki)) and ensure they are created as secrets in the MC's cluster namespace.
- Convert kube-vip kubeconfig to JSON and remove all whitespace: `yq -o json kubeconfig | jq . -c`

### Github

- Pinniped requires an [app](https://pinniped.dev/docs/howto/supervisor/configure-supervisor-with-github/)
- oauth2 proxy needs a oauth app for every domain being secured

### Flux

- Pre-create credentials for [authenticating to github](https://fluxcd.io/flux/cmd/flux_create_secret_git/)

### Cloudflare

- Create token for external-dns to authenticate with
- Create token for cert-manager to authenticate with

### Proxmox

- Create credentials for CCM

```
pveum role add proxmox-cloud-controller-manager -privs "VM.Audit"
pveum user add ccm-room101-a7d-prod1@pve
pveum aclmod / -user ccm-room101-a7d-prod1@pve -role proxmox-cloud-controller-manager
pveum user token add ccm-room101-a7d-prod1@pve ccm -privsep 0
```

- Add a new pool to Proxmox for the new WC: `pvesh create /pools -poolid ${CLUSTER_NAME} -comment "Resource pool for cluster-api ${CLUSTER} Workload Cluster"`
- Update `capmox` user to allow it to access the new pool: `pveum aclmod /pool/${CLUSTER_NAME} -user capmox-room101-a7d-mc@pve -role PVEVMAdmin --propagate 0`

### Storage

Create pools and credentials in Truenas (see [this](https://www.lisenet.com/2021/moving-to-truenas-and-democratic-csi-for-kubernetes-persistent-storage/))
