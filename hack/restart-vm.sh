#!/usr/bin/env bash

REPO_BASE="$(git rev-parse --show-toplevel)"
source "${REPO_BASE}/hack/_credentials.sh"

_vmid="${1}"

TEMPFILE=$(mktemp)

if curl -k -s -d "username=${PROXMOX_API_USER}" \
  --data-urlencode "password=${PROXMOX_API_PASS}" \
  "${PROXMOX_API_URL}/access/ticket" > ${TEMPFILE} ; then
    _ticket=$(jq -r .data.ticket ${TEMPFILE})
    _csrftoken=$(jq -r .data.CSRFPreventionToken ${TEMPFILE})
    echo "Got ticket"
else
  echo "Failed to get ticket"
  exit 1
fi

_host=$(curl -k -s -b "PVEAuthCookie=${_ticket}" \
  -H "CSRFPreventionToken: ${_csrftoken}" \
  -X GET "${PROXMOX_API_URL}/cluster/resources?type=vm" \
  | jq -r --argjson vmid "$_vmid" '.data[] | select(.vmid==$vmid) | .node')

curl -k -s -b "PVEAuthCookie=${_ticket}" \
  -H "CSRFPreventionToken: ${_csrftoken}" \
  -X POST "${PROXMOX_API_URL}/nodes/${_host}/qemu/${_vmid}/status/reset"
