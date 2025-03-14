#!/usr/bin/env bash

echo -n "Enter Kubernetes cluster name (e.g. room101-a7d-mc): "
read -r CLUSTER_NAME

if [ -z $CLUSTER_NAME ]; then
    exit 1
fi

echo -n "Enter Talos version to download: "
read -r TALOS_VERSION

if [ -z $TALOS_VERSION ]; then
    exit 1
fi

echo -n "Enter VM ID for the new template: "
read -r VM_ID

if [ -z $VM_ID ]; then
    exit 1
fi

echo -n "Enter PVE server IP to upload the image to: "
read -r PVE_SERVER

if [ -z $PVE_SERVER ]; then
    exit 1
fi

source hack/_utils.sh

SCHEMATIC_ID=$(curl -s --data-binary "@${REPO_BASE}/flux/clusters/${CLUSTER_NAME}/factory.talos.dev/schematic.yaml" https://factory.talos.dev/schematics | jq -r .id)

ssh ${PVE_SERVER} \
    "echo "Downloading Talos v${TALOS_VERSION} for schematic ID ${SCHEMATIC_ID}" \
    ; wget -q https://factory.talos.dev/image/${SCHEMATIC_ID}/v${TALOS_VERSION}/nocloud-amd64.raw.xz -O /tmp/talos-${TALOS_VERSION}.raw.xz \
    && unxz < /tmp/talos-${TALOS_VERSION}.raw.xz > /tmp/talos-${TALOS_VERSION}.raw \
    && sudo qm create ${VM_ID} --name talos-${TALOS_VERSION} \
        --cores 1 \
        --memory 1024 \
        --bootdisk scsi0 \
        --boot order=scsi0 \
        --net0 virtio,bridge=vmbr0 \
        --bootdisk scsi0 \
        --scsihw virtio-scsi-pci \
        --cpu \"custom-talos-kvm64\" \
        --ostype l26 \
        --agent enabled=1 \
        --onboot=1 \
        --description \"Talos v${TALOS_VERSION} (schematic ID ${SCHEMATIC_ID})\" \
        --tags \"talos_version_v${TALOS_VERSION},schematic_id_${SCHEMATIC_ID}\" \
    && sudo qm importdisk ${VM_ID} /tmp/talos-${TALOS_VERSION}.raw nfs-vm-images -format raw \
    && sudo qm set ${VM_ID} --scsihw virtio-scsi-pci --scsi0 nfs-vm-images:${VM_ID}/vm-${VM_ID}-disk-0.raw \
    && sudo qm template ${VM_ID} \
    ; rm /tmp/talos-${TALOS_VERSION}.raw*"
