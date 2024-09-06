# hacks

## `pki` dir

Contains resources which help manipulate anything to do with cluster certificates.

## `opsense-add-bgp-neighbours.sh`

Used to add BGP neighbours to OPNsense firewall for all IP addresses in a range. This is necessary because nodes created with ClusterAPI may use any IP inside a subnet.

## restart-vm.sh

Encrypt:

```
vault write transit/encrypt/tf-encryption-key -format=json plaintext=$(cat hack/restart-vm.sh | base64 -w 0) | jq -r .data.ciphertext > hack/restart-vm.sh.enc
```

Decrypt:
```
vault write transit/decrypt/tf-encryption-key -format=json ciphertext=$(cat hack/restart-vm.sh.enc) | jq -r .data.plaintext | base64 -d > hack/restart-vm.sh
```
