#!/bin/bash

parse_args () {
  args=$@

  if [ $# -eq 0 ] ; then
    echo -e "\nPass either --encrypt or --decrypt as an argument\n"
    exit 0
  fi

  while [[ $# -gt 0 ]]; do
    case $1 in
      -d|--decrypt)
        decrypt
        exit 0
        ;;
      -e|--encrypt)
        encrypt
        exit 0
        ;;
    esac
  done
}

decrypt () {
    echo -en "\nAre you sure you want to overwrite the existing bootstrap script? [y/N]: "
    read -r answer

    if [ "${answer}" != "y" ] && [ "${answer}" != "Y" ]; then
        echo -e "\nAborting decryption"
        exit 0
    fi

    echo -e "\nTaking a backup of the current bootstrap script"
    _backup_file="hack/recreate-bootstrap.sh.$(date +%s)"
    cp hack/recreate-bootstrap.sh $_backup_file

    echo -e "\nDecrypting bootstrap script"
    vault write transit/decrypt/tf-encryption-key -format=json \
        ciphertext=$(cat hack/recreate-bootstrap.sh.enc) \
        | jq -r .data.plaintext | base64 -d > hack/recreate-bootstrap.sh && \
        echo -e "\nDecryption complete"

    echo -ne "\nRemove backup? [y/N]: "
    read -r answer

    if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
        rm $_backup_file && \
            echo -e "\nBackup removed\n"
    fi
}

encrypt () {
    echo "Encrypting bootstrap script"
    vault write transit/encrypt/tf-encryption-key -format=json \
        plaintext=$(cat hack/recreate-bootstrap.sh | base64 -w 0) \
        | jq -r .data.ciphertext > hack/recreate-bootstrap.sh.enc && \
        echo "Encryption complete"
}

parse_args $@
