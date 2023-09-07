# PKI

The following commands can be used to generate client certificates for `kubeconfig` and `talosconfig` access before cluster creation.

## kubeconfig

1. Extract `k8s` CA and key from cluster's Talos secrets and place in this directory.

2. Generate kubeconfig client certs:

```
cd k8s
cfssl gencert -ca=../k8s-ca.crt -ca-key=../k8s-ca.key -config=../ca-config.json -profile=kubernetes admin.csr.json | cfssljson -bare admin
```

3. Create kubeconfig from template:

```
export CA_B64=$(cat ca.pem | base64 -w0)
export CRT_B64=$(cat cert.pem | base64 -w0)
export KEY_B64=$(cat key.pem | base64 -w0)
export CLUSTER=room101-a7d-mc
export API_URI="k8s.room101-a7d-mc.lab.a7d.dev"
export API_PORT=6443
envsubst < kubeconfig.template > $CLUSTER.kubeconfig
```

## talosconfig

1. Extract `os` CA and key from cluster's Talos secrets and place in this directory.

2. Generate talosconfig client certs:

```
cd talos
cfssl gencert -ca=../talos-ca.crt -ca-key=../talos-ca.key -config=../ca-config.json -profile=talos talos.csr.json | cfssljson -bare talos
```

3. Create talosconfig from template:

```
export CA_B64=$(cat ca.pem | base64 -w0)
export CRT_B64=$(cat cert.pem | base64 -w0)
export KEY_B64=$(cat key.pem | base64 -w0)
export CLUSTER=room101-a7d-mc
export ENDPOINT=0.0.0.0
envsubst < talosconfig.template > $CLUSTER.talosconfig
```
