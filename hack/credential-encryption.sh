#!/bin/bash

REPO_BASE="$(git rev-parse --show-toplevel)"

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
    echo -en "\nAre you sure you want to overwrite the existing credentials file? [y/N]: "
    read -r answer

    if [ "${answer}" != "y" ] && [ "${answer}" != "Y" ]; then
        echo -e "\nAborting decryption"
        exit 0
    fi

    echo -e "\nTaking a backup of the current credentials file"
    _backup_file="_credentials.sh.$(date +%s)"
    cp "${REPO_BASE}/hack/_credentials.sh" "${REPO_BASE}/hack/$_backup_file"

    echo -e "\nDecrypting credentials file"
    vault write transit/decrypt/tf-encryption-key -format=json \
        ciphertext=$(cat "${REPO_BASE}/hack/_credentials.sh.enc") \
        | jq -r .data.plaintext | base64 -d > "${REPO_BASE}/hack/_credentials.sh" && \
        echo -e "\nDecryption complete"

    echo -ne "\nRemove backup? [y/N]: "
    read -r answer

    if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
        rm $_backup_file && \
            echo -e "\nBackup removed\n"
    fi
}

encrypt () {
    echo "Encrypting credentials file"
    vault write transit/encrypt/tf-encryption-key -format=json \
        plaintext=$(cat "${REPO_BASE}/hack/_credentials.sh" | base64 -w 0) \
        | jq -r .data.ciphertext > "${REPO_BASE}/hack/_credentials.sh.enc" && \
        echo "Encryption complete"
}

parse_args $@
