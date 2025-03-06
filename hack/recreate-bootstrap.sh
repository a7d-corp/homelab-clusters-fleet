#!/bin/bash

REPO_BASE="$(git rev-parse --show-toplevel)"

if [ ! -f "${REPO_BASE}/hack/_credentials.sh" ]; then
  echo "Could not find _credentials.sh, exiting"
  exit 1
else
  source "${REPO_BASE}/hack/_credentials.sh"
fi

parse_args () {
  args=$@

  if [ $# -eq 0 ] ; then
    show_help
    exit 0
  fi

  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_help
        exit 0
        ;;
      -a|--auto)
        full_auto
        exit 0
        ;;
      -r|--recreate)
        recreate_cluster
        exit 0
        ;;
      --redeploy-mc)
        redeploy_mc
        exit 0
        ;;
      -k|--kill-cluster)
        kill_cluster
        exit 0
        ;;
      -f|--flux)
        bootstrap_flux
        exit 0
        ;;
      -d|--deploy-mc)
        deploy_mc
        exit 0
        ;;
      -s|--scale-down)
        disable_bootstrap_cluster
        exit 0
        ;;
    esac
  done
}

full_auto() {
    export _kubectl="kubectl --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"
    export _flux="flux --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"

    echo -n "Potentially destroy bootstrap cluster? [y/N] "
    read -r answer

    if [ "${answer}" != "y" ] && [ "${answer}" != "Y" ]
    then
        echo "Aborting"
        exit 0
    fi

    recreate_cluster
    bootstrap_flux
    deploy_mc
}

redeploy_mc() {
    export _kubectl="kubectl --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"
    export _flux="flux --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"

    # stop flux reconciling gitrepo
    ${_flux} suspend ks flux-system -n flux-system

    # suspend capi resources kustomization
    ${_flux} suspend ks 20-talos-cluster-resources -n cluster-room101-a7d-mc

    # delete cluster
    ${_kubectl} delete cluster room101-a7d-mc -n cluster-room101-a7d-mc

    # wait for cluster to be deleted
    ${_kubectl} wait --for=delete cluster/room101-a7d-mc --timeout=300s

    # resume capi resources kustomization
    ${_flux} resume ks 20-talos-cluster-resources -n cluster-room101-a7d-mc

    # resume flux reconciling gitrepo
    ${_flux} resume ks flux-system -n flux-system
}

kill_cluster() {
    export _kubectl="kubectl --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"
    export _flux="flux --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"

    # stop flux reconciling gitrepo
    ${_flux} suspend ks flux-system -n flux-system

    # suspend capi resources kustomization
    ${_flux} suspend ks 20-talos-cluster-resources -n cluster-room101-a7d-mc

    # delete cluster
    ${_kubectl} delete cluster room101-a7d-mc -n cluster-room101-a7d-mc

    # wait for cluster to be deleted
    ${_kubectl} wait --for=delete cluster/room101-a7d-mc --timeout=300s
}

recreate_cluster() {
    set -x
    export _kubectl="kubectl --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"
    export _flux="flux --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"
    export _remote_talosctl="talosctl/talosctl-1.7.0-alpha.1"

    # ensure the cluster is accessible first
    if ! ${_kubectl} get no > /dev/null 2>&1 ; then
        POD_COUNT=100
    else
        POD_COUNT=$(kubectl get po -A -o custom-columns=NAME:.metadata.name --no-headers=true | wc -l)
    fi
    if [ "$POD_COUNT" -gt "11" ] ; then
        ssh 172.25.100.2 \
        "${_remote_talosctl} cluster destroy --name sidero-bootstrap \
        ; rm ~/.talos/config \
        ; ${_remote_talosctl} cluster create \
            --name sidero-bootstrap \
            -p 51821:51821/udp \
            --workers 0 \
            --config-patch '[{\"op\": \"add\", \"path\": \"/cluster/allowSchedulingOnControlPlanes\", \"value\": true}]' \
            --nameservers 10.101.0.2,10.101.0.3 \
            --docker-host-ip 172.25.100.2 \
            --endpoint 172.25.100.2 \
            --memory 6144 \
        ; ${_remote_talosctl} config node 172.25.100.2"

        cd $(git rev-parse --show-toplevel)
        rm ~/.talos/config
        ssh 172.25.100.2 'cat .talos/config' > ~/.talos/config
        talosctl kubeconfig $(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig --force --talosconfig ~/.talos/config
        sed -i 's/https.*/https:\/\/172.25.100.2:6443/g' $(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig

        sed -zi 's/suspend: false/suspend: true/2' $(git rev-parse --show-toplevel)/flux/clusters/bootstrap/20-talos-cluster.yaml \
            && git add $(git rev-parse --show-toplevel)/flux/clusters/bootstrap/20-talos-cluster.yaml \
            && git commit -m "suspend reconciliation of bootstrap cluster Talos resources" \
            && git push

        # get root vault token from Bitwarden
        export VAULT_TOKEN=$(rbw get "Vault token")

        ${_kubectl} create ns cluster-room101-a7d-mc
        ${_kubectl} create ns flux-system
        ${_kubectl} create ns proxmox-system
        vault kv get -mount=cluster-room101-a7d-mc -field=data sops-age \
            | base64 -d | ${_kubectl} apply -n flux-system -f -
        vault kv get -mount=cluster-room101-a7d-mc -field=data sops-age \
            | base64 -d | ${_kubectl} apply -n cluster-room101-a7d-mc -f -
        ${_kubectl} create secret generic flux-system -n flux-system \
            --from-literal=identity="$(vault kv get -mount=cluster-room101-a7d-mc -field=identity flux-bootstrap-deploy-key | base64 -d)" \
            --from-literal=identity.pub="$(vault kv get -mount=cluster-room101-a7d-mc -field=identity.pub flux-bootstrap-deploy-key | base64 -d)" \
            --from-literal=known_hosts="$(vault kv get -mount=cluster-room101-a7d-mc -field=known_hosts flux-bootstrap-deploy-key | base64 -d)"
    else
        log_info "${POD_COUNT} pods running, skipping cluster recreation"
    fi
}

bootstrap_flux() {
    export _flux="flux --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"

    ${_flux} bootstrap github --owner a7d-corp --repository homelab-clusters-fleet \
        --branch main --path flux/clusters/bootstrap --secret-name flux-system
}

deploy_mc() {
    log_info "Deploying MC cluster resources"
    cd $(git rev-parse --show-toplevel)
    sed -i 's/suspend: true/suspend: false/g' flux/clusters/bootstrap/20-talos-cluster.yaml && \
        git add flux/clusters/bootstrap/20-talos-cluster.yaml && \
        git commit -m "resume reconciliation of bootstrap cluster Talos resources" && \
        git push
}

disable_bootstrap_cluster() {
    export _kubectl="kubectl --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"

    for deploy in $(${_kubectl} get deploy -n flux-system -o custom-columns=NAME:.metadata.name --no-headers=true); do
        ${_kubectl} scale deploy $deploy -n flux-system --replicas=0
    done

    ${_kubectl} scale deploy capmox-controller-manager -n proxmox-system --replicas 0
}

show_help() {
    echo "Creation flags:

-a | --auto             Do all the things
-k | --kill-cluster     Destroy MC cluster resources
   | --redeploy-mc      Recreate MC cluster resources

-r | --recreate         Recreate bootstrap cluster
-f | --flux             Deploy flux into bootstrap cluster
-d | --deploy-mc        Deploy MC Cluster resources
-s | --scale-down       Scale down bootstrap cluster controllers (flux, capmox)"
}

log_info() {
    echo -e "\nINFO: ${1}\n"
}

parse_args $@
