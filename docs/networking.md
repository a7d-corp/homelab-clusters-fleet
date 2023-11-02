# Sidero clusters

## Cluster networking

- Each cluster is in it's own VLAN with a `/27` subnet.
- The first two IPs in the subnet are reserved.
- IPs 3-5 are statically configured for the control plane instances.
- The remaining IPs are allocated by DHCP to worker instances.

Using the management cluster as an example:

- `172.25.100.1` - `172.25.100.2`:
  - Reserved.
- `172.25.100.3`:
  - Controlplane instance #1. 
- `172.25.100.4`:
  - Control plane instance #2.
- `172.25.100.5`:
  - Control plane instance #3.
- `172.25.100.6` - `172.25.100.30`:
  - DHCP allocated to worker instances.

## Loadbalancer services

- Each cluster is allocated a `/27` service subnet (e.g. `172.27.0.0/27`).
- BGP is used to advertise IPs which are allocated by Cilium to Loadbalancer services.
- IPs in service subnets are not routed unless allocated to a Loadbalancer.
- As any node in the cluster's subnet can advertise a route to service IPs, Opnsense must be configured to allow any IP in the cluster's subnet to announce. This is handled by the [opsense-add-bgp-neighbours.sh](hack/opsense-add-bgp-neighbours.sh) script.
