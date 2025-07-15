#!/usr/bin/env bash

echo -n "Enter Kubernetes cluster name (e.g. room101-a7d-mc): "
read -r CLUSTER_NAME

if [ -z $CLUSTER_NAME ]; then
    exit 1
fi

source hack/_utils.sh

cp_machine_salt=$(openssl rand -hex 3)
worker_machine_salt=$(openssl rand -hex 3)
worker_tct_salt=$(openssl rand -hex 3)

CONFIGMAP_FILE_PATH="${REPO_BASE}/flux/clusters/${CLUSTER_NAME}/cluster-prereqs/cluster-vars-configmap.yaml"

sed -i "s/  CP_MACHINE_SALT.*/  CP_MACHINE_SALT: \"${cp_machine_salt}\"/" "${CONFIGMAP_FILE_PATH}"
sed -i "s/  WORKER_MACHINE_SALT.*/  WORKER_MACHINE_SALT: \"${worker_machine_salt}\"/" "${CONFIGMAP_FILE_PATH}"
sed -i "s/  WORKER_TCT_SALT.*/  WORKER_TCT_SALT: \"${worker_tct_salt}\"/" "${CONFIGMAP_FILE_PATH}"
