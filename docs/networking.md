# ClusterAPI clusters

## Cluster networking

- Each cluster is in it's own VLAN with a `/27` subnet.
- The first ten IPs in the subnet are reserved.
- The remaining IPs are allocated by the `clusterapi-ipam-in-cluster` controller to instances.

Using the management cluster as an example:

- Subnet: `172.25.100.0/27`
- IPAM range: `172.25.100.10` - `172.25.100.30`
- Loadbalancer subnet: `172.27.0.32/27`
- Kubernetes API VIP: `172.27.0.61`
- Nginx ingress VIP: `172.27.0.62`

## Kubernetes API VIP

- `kube-vip` is deployed via static pods on the control plane nodes in order to advertise the VIP via BGP.

## Loadbalancer services

- Each cluster is allocated a `/27` service subnet (e.g. `172.27.0.0/27`).
- BGP is used to advertise IPs which are allocated by Cilium to Loadbalancer services.
- IPs in service subnets are not routed unless allocated to a Loadbalancer.
- As any node in the cluster's subnet can advertise a route to service IPs, Opnsense must be configured to allow any IP in the cluster's subnet to announce. This is handled by the [opsense-add-bgp-neighbours.sh](hack/opsense-add-bgp-neighbours.sh) script.