# PKI

The following commands can be used to generate client certificates for `kubeconfig` and `talosconfig` access before cluster creation.

## kubeconfig

1. Extract `k8s` CA and key from cluster's Talos secrets and place in this directory.

2. Generate kubeconfig client certs:

```
cd k8s
cfssl gencert -ca=../k8s-ca.crt -ca-key=../k8s-ca.key -config=../ca-config.json -profile=kubernetes admin.csr.json | cfssljson -bare admin
```

## talosconfig

1. Extract `os` CA and key from cluster's Talos secrets and place in this directory.

2. Generate talosconfig client certs:

```
cd talos
cfssl gencert -ca=../talos-ca.crt -ca-key=../talos-ca.key -config=../ca-config.json -profile=talos talos.csr.json | cfssljson -bare talos
```
