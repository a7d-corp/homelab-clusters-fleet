#!/bin/bash

# get the current cluster name from the admin kubeconfig
CLUSTER_NAME=$(yq -r .contexts[0].context.cluster $KUBECONFIG)

if [ -z ${CLUSTER_NAME} ]; then
  echo "Failed to get the cluster name from the kubeconfig"
  exit 1
else
    echo "Get the Pinniped kubeconfig for cluster: ${CLUSTER_NAME}? (y/N) "
    read -r answer

    if [ "${answer}" != "y" ] && [ "${answer}" != "Y" ]
    then
        echo "Aborting"
        exit 0
    fi
fi

KUBECONFIG_PATH="${HOME}/.kube/clusters/pinniped-${CLUSTER_NAME}.yaml"

if [ -f $KUBECONFIG_PATH ]; then
    echo "The Pinniped kubeconfig already exists at ${KUBECONFIG_PATH}; overwrite it? (y/N) "
    read -r answer

    if [ "${answer}" != "y" ] && [ "${answer}" != "Y" ]
    then
        echo "Not overwriting the existing kubeconfig"
        exit 0
    fi
fi

pinniped get kubeconfig --concierge-mode ImpersonationProxy > ${KUBECONFIG_PATH}

if [ $? -ne 0 ]; then
    echo "Failed to get the Pinniped kubeconfig"
    exit 1
fi
