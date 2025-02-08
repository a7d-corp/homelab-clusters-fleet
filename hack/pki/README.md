# PKI

The following commands can be used to generate client certificates for `kubeconfig` and `talosconfig` access before cluster creation.

## kubeconfig

1. Extract `k8s` CA and key from cluster's Talos secrets and place in this directory.

```
export CLUSTER=room101-a7d-mc
BASE_DIR=$(git rev-parse --show-toplevel)
SECRETS_FILE=${BASE_DIR}/flux/kubernetes/clusters/${CLUSTER}/talos-secrets.yaml

sops -i -d ${SECRETS_FILE}

yq .data.bundle -r $SECRETS_FILE \
    | base64 -d \
    | yq .certs.k8s.crt -r
    | base64 -d > ${BASE_DIR}/hack/pki/k8s/tmp/k8s-ca.crt
yq .data.bundle -r $SECRETS_FILE \
    | base64 -d \
    | yq .certs.k8s.key -r \
    | base64 -d > ${BASE_DIR}/hack/pki/k8s/tmp/k8s-ca.key

git checkout -- ${SECRETS_FILE}
```

2. Generate kubeconfig client certs:

```
cd ${BASE_DIR}/hack/pki/k8s

cfssl genkey k8s-admin-client.csr.json \
    | cfssljson -bare tmp/k8s-admin-client

cfssl gencert -ca tmp/k8s-ca.crt \
    -ca-key=tmp/k8s-ca.key \
    -config=k8s-admin-client-config.json \
    -profile=k8s-admin-client k8s-admin-client-csr.json \
    | cfssljson -bare tmp/k8s-admin-client
```

3. Create kubeconfig from template:

```
cd ${BASE_DIR}/hack/pki/k8s
export CA_B64=$(cat tmp/k8s-ca.crt | base64 -w0)
export CRT_B64=$(cat tmp/k8s-admin-client.pem | base64 -w0)
export KEY_B64=$(cat tmp/k8s-admin-client-key.pem | base64 -w0)
export API_URI="k8s.room101-a7d-mc.lab.a7d.dev"
export API_PORT=6443
envsubst < kubeconfig.template > $CLUSTER.kubeconfig
```

4. Clean up

```
rm tmp/*
```

## talosconfig

1. Extract `os` CA and key from cluster's Talos secrets and place in this directory.

```
export CLUSTER=room101-a7d-mc
BASE_DIR=$(git rev-parse --show-toplevel)
SECRETS_FILE=${BASE_DIR}/flux/kubernetes/clusters/${CLUSTER}/talos-secrets.yaml

sops -i -d ${SECRETS_FILE}

yq .data.bundle -r $SECRETS_FILE \
    | base64 -d \
    | yq .certs.os.crt -r \
    | base64 -d > ${BASE_DIR}/hack/pki/talos/tmp/talos-ca.crt

yq .data.bundle -r $SECRETS_FILE \
    | base64 -d \
    | yq .certs.os.key -r \
    | base64 -d > ${BASE_DIR}/hack/pki/talos/tmp/talos-ca.key

git checkout -- ${SECRETS_FILE}
```

2. Generate talosconfig client certs:

```
cd ${BASE_DIR}/hack/pki/talos

cfssl genkey talos-client-csr.json \
    | cfssljson -bare tmp/talos-client

cfssl gencert -ca tmp/talos-ca.crt \
    -ca-key=tmp/talos-ca.key \
    -config=talos-client-config.json \
    -profile=talos-client talos-client-csr.json \
    | cfssljson -bare tmp/talos-client
```

3. Create talosconfig from template:

```
cd ${BASE_DIR}/hack/pki/talos
export CA_B64=$(cat tmp/talos-ca.crt | base64 -w0)
export CRT_B64=$(cat tmp/talos-client.pem | base64 -w0)
export KEY_B64=$(cat tmp/talos-client-key.pem | base64 -w0)
export ENDPOINT=0.0.0.0
envsubst < talosconfig.template > $CLUSTER.talosconfig
```

4. Clean up

```
rm tmp/*
```
