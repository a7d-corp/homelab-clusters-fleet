# Talos image factory

The image factory is used to generate images which are customised with any required extensions and configuration.

The image's schematic ID is retrieved by POSTing the schematic definition yaml to the factory API.

```bash
export CLUSTER_NAME=cluster-1

SCHEMATIC_ID=$(curl -s --data-binary "@flux/clusters/${CLUSTER_NAME}/factory.talos.dev/schematic.yaml" https://factory.talos.dev/schematics | jq -r .id)
```

Download the customised image for a specific Talos version (may take a little while to start as the image is generated on the fly).
```bash
export TALOS_VERSION=1.9.4

wget https://factory.talos.dev/image/${SCHEMATIC_ID}/v${TALOS_VERSION}/nocloud-amd64.raw.xz -O /tmp/talos-${TALOS_VERSION}.raw.xz
```

```bash
export PVE_SERVER=10.101.2.121

rsync -avP /tmp/talos-${TALOS_VERSION}.raw.xz root@${PVE_SERVER}:/tmp/
```

```bash
ssh ${PVE_SERVER}

export VM_ID=902

unxz < /tmp/talos-${TALOS_VERSION}.raw.xz > /tmp/talos-${TALOS_VERSION}.raw

qm create ${VM_ID} --name talos-${TALOS_VERSION} \
    --cores 1 \
    --memory 1024 \
    --bootdisk scsi0 \
    --boot order=scsi0 \
    --net0 virtio,bridge=vmbr0 \
    --bootdisk scsi0 \
    --scsihw virtio-scsi-pci \
    --cpu "custom-talos-kvm64" \
    --ostype l26 \
    --agent enabled=1 \
    --onboot=1 \
    --description "Talos v${TALOS_VERSION} (schematic ID ${SCHEMATIC_ID})" \
    --tags "talos_version_v${TALOS_VERSION},schematic_id_${SCHEMATIC_ID}"
qm importdisk ${VM_ID} /tmp/talos-${TALOS_VERSION}.raw nfs-vm-images -format raw
qm set ${VM_ID} --scsihw virtio-scsi-pci --scsi0 nfs-vm-images:${VM_ID}/vm-${VM_ID}-disk-0.raw
qm template ${VM_ID}
```

See [template upload script](/hack/talos-template-upload.sh)