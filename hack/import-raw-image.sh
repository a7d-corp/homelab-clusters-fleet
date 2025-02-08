# https://factory.talos.dev/image/6f4f1561bdd96a21fc713838db289cce7c5dde02af6575b66b04b008e6516144/v1.9.3/nocloud-amd64.raw.xz
qm create 901 --name "talos-1.9.3" --memory 1024 --cores 1 --net0 virtio,bridge=vmbr0
qm importdisk 901 nocloud-amd64.raw nfs-vm-images -format raw
qm set 901 --scsihw virtio-scsi-pci --scsi0 nfs-vm-images:901/vm-901-disk-0.raw
qm set 901 --boot order=scsi0
qm set 901 -cpu "custom-talos-kvm64"
qm set 901 --agent enabled=1
qm template 901
