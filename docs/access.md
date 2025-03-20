# Cluster access

## DNS records

### Kubernetes API

`k8s.<cluster id>.lab.a7d.dev` > `kube-vip`-managed VIP.

### Kubernetes API via Pinniped

`concierge.<cluster id>.lab.a7d.dev` > `ingress IP`

### Dex

`dex.<cluster id>.lab.a7d.dev` > `ingress IP`

### Dex k8s authenticator

`login.<cluster id>.lab.a7d.dev` > `ingress IP`

### Oauth2 proxy

`oauth2-proxy.<cluster id>.lab.a7d.dev` > `ingress IP`
`oauth2-proxy.<cluster id>.lab.analbeard.com` > `ingress IP`

## Pinniped

Pinniped is used to faciliate access to the Kubernetes API. It is configured to use a Github app for authentication.

### Implementation details

- Pinniped's `supervisor` deployment runs in the management cluster.
- Each WC runs the Pinniped `concierge` which is configured to use the [supervisor federation domain](/flux/apps/base/pinniped-supervisor/post-setup/federation-domain.yaml).
- Each `concierge` deployment runs in [ImpersonationProxy mode](flux/apps/base/pinniped-concierge/helmrelease.yaml#L27). This is because Talos clusters do not allow anonymous auth to the Kubernetes API by default.
- An [ingress](/flux/apps/base/pinniped-concierge/ingress-impersonation-proxy.yaml) is created to expose the ImpersonationProxy to clients.
