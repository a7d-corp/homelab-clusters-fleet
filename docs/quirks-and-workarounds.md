# Quirks and workarounds

Here we document the various hacks and oddities which have been necessary in order to get Talos clusters provisioned via `cluster-api-provider-proxmox`.

### kube-vip API loadbalancer configuration

Running `kube-vip` as static pods on the control plane requires a kubeconfig with enough privileges - the upstream manifest uses `/etc/kubernetes/admin.conf` but this is specific to clusters provisioned by Kubeadm. When using Talos as an OS, this file does not exist and so we need to provide a kubeconfig instead.

Due to the fact that Talos is an immutable OS, we have to use some workarounds:

- A kubeconfig is created using the [pki](/hack/pki/) directory and then [stored in a secret](/flux/clusters/room101-a7d-mc/cluster-prereqs/cluster-vars-secret.yaml#L6)
- The kubeconfig secret is then [written out to each control plane node](/flux/kubernetes/clusters/room101-a7d-mc/patches/taloscontrolplane-kube-vip-kubeconfig.yaml) to a writeable location.
- `kube-vip` [consumes](https://github.com/a7d-corp/homelab-clusters-fleet/blob/main/flux/kubernetes/patches/shared-patches/controlplane/machine-pods.yaml#L70) the kubeconfig.

### cluster-vars configmap in the kube-public namespace

`pinniped` uses the `cluster-vars` configmap in the `kube-public` namespace in order to scaffold the kubeconfig which is generated when running `pinniped get kubeconfig`, however this configmap does not exist when using the Talos bootstrap provider. To work around this, it is [created manually](/flux/clusters/room101-a7d-mc/cluster-prereqs/configmap-cluster-values.yaml) (as we already have the cluster's CA cert ahead of cluster creation).