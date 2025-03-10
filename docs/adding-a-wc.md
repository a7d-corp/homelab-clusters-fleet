# Adding a new WC

## Things to remember

### Networking

- Add BGP pool for VIPs to [Opnsense](https://opnsense.int.analbeard.com/ui/quagga/bgp/index)
- Ensure node IPs are added to Opnsense as BGP neighbours
- K8S API VIP is the last-but-one IP in the BGP pool
- NGINX VIP is the last IP in the BGP pool
- Add relevant DNS records to static mapping in blocky (temporarily)
- Add proxied domains to Haproxy config (if necessary)

### Github

- Pinniped requires an [app](https://pinniped.dev/docs/howto/supervisor/configure-supervisor-with-github/)
- oauth2 proxy needs a oauth app for every domain being secured

### Flux

- Pre-create credentials for [authenticating to github](https://fluxcd.io/flux/cmd/flux_create_secret_git/)

### Cloudflare

- Create token for external-dns to authenticate with
- Create token for cert-manager to authenticate with

### Proxmox

- Create credentials for CAPI operator
- Create credentials for CCM
- Create credentials for CSI