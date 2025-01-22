#!/bin/bash

REPO_BASE="$(git rev-parse --show-toplevel)"
source "${REPO_BASE}/hack/_credentials.sh"

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
      --dns)
        reset_dns
        exit 0
        ;;
      --check-dns)
        check_dns
        exit 0
        ;;
      -f|--flux)
        bootstrap_flux
        exit 0
        ;;
      -d|--deploy)
        deploy_mc
        exit 0
        ;;
      -s|--scale-down)
        disable_bootstrap_cluster
        exit 0
        ;;
      -q|--qemu)
        destroy_qemu
        exit 0
        ;;
      --redeploy-qemu)
        redeploy_qemu
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
    reset_dns
    bootstrap_flux
    wait_on_machines
    deploy_mc
}

redeploy_mc() {
    export _kubectl="kubectl --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"
    export _flux="flux --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"

    # stop flux reconciling gitrepo
    ${_flux} suspend ks flux-system -n flux-system

    # suspend cluster kustomization
    ${_flux} suspend ks 21-talos-cluster-config -n cluster-room101-a7d-mc

    # suspend proxmox machine kustomization
    ${_flux} suspend ks 20-talos-machine-config -n cluster-room101-a7d-mc

    # delete cluster
    ${_kubectl} delete cluster room101-a7d-mc -n cluster-room101-a7d-mc

    # delete all qemu machines
    for qemu in $(${_kubectl} get qemu -o custom-columns=NAME:.metadata.name --no-headers=true); do ${_kubectl} delete qemu $qemu ; done

    # scale proxmox operator down
    ${_kubectl} scale deploy proxmox-operator -n proxmox-operator --replicas=0

    # delete all servers
    for server in $(${_kubectl} get server -o custom-columns=NAME:.metadata.name --no-headers=true); do ${_kubectl} delete server $server ; done

    # recreate proxmox machines
    ${_flux} resume ks 20-talos-machine-config -n cluster-room101-a7d-mc

    # scale proxmox operator up
    ${_kubectl} scale deploy proxmox-operator -n proxmox-operator --replicas=1

    until [ `${_kubectl} get server --no-headers=true | wc -l` == 3 ]; do
        log_info "waiting for all servers to be created"
        sleep 10
    done

    log_info "waiting for servers to be powered on"

    ${_kubectl} wait --for=jsonpath='{.status.power}'=on server 203e63cb-a8aa-4bf8-a5b6-333090507777 --timeout=600s
    ${_kubectl} wait --for=jsonpath='{.status.power}'=on server 461b9ad1-3ff0-4bef-8e1e-0dbfc1d8fa43 --timeout=600s
    ${_kubectl} wait --for=jsonpath='{.status.power}'=on server 498eeb6c-76dd-4fb1-9bc4-bb940e8803ff --timeout=600s

    log_info "all servers powered on"

    # recreate cluster resources
    ${_flux} resume ks 21-talos-cluster-config -n cluster-room101-a7d-mc

    # resume flux reconciling gitrepo
    ${_flux} resume ks flux-system -n flux-system
}

recreate_cluster() {
    export _kubectl="kubectl --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"
    export _flux="flux --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"

    # ensure the cluster is accessible first
    if ! ${_kubectl} get no > /dev/null 2>&1 ; then
        POD_COUNT=100
    else
        POD_COUNT=$(kubectl get po -A -o custom-columns=NAME:.metadata.name --no-headers=true | wc -l)
    fi
    if [ "$POD_COUNT" -gt "11" ] ; then
#        ssh 172.25.100.2 \
#         "kind delete cluster --name mc-bootstrap \
#         ; kind create cluster --config ~/kind.yaml --kubeconfig ~/kind.kubeconfig"

        ssh 172.25.100.2 \
        "talosctl cluster destroy --name sidero-bootstrap \
        ; rm ~/.talos/config \
        ; talosctl cluster create \
            --name sidero-bootstrap \
            -p 69:69/udp,8081:8081/tcp,51821:51821/udp \
            --workers 0 \
            --config-patch '[{\"op\": \"add\", \"path\": \"/cluster/allowSchedulingOnMasters\", \"value\": true}]' \
            --nameservers 10.101.0.2,10.101.0.3 \
            --docker-host-ip 172.25.100.2 \
            --endpoint 172.25.100.2 \
            --memory 6144 \
        ; talosctl config node 172.25.100.2"

        cd $(git rev-parse --show-toplevel)
        rm ~/.talos/config
        ssh 172.25.100.2 'cat .talos/config' > ~/.talos/config
        talosctl kubeconfig $(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig --force --talosconfig ~/.talos/config
        sed -i 's/https.*/https:\/\/172.25.100.2:6443/g' $(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig

#        ssh 172.25.100.2 'cat ~/kind.kubeconfig' > $(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig

        sed -zi 's/suspend: false/suspend: true/2' $(git rev-parse --show-toplevel)/clusters/bootstrap/20-talos-cluster.yaml \
            && git add $(git rev-parse --show-toplevel)/clusters/bootstrap/20-talos-cluster.yaml \
            && git commit -m "suspend reconciliation of bootstrap cluster Talos resources" \
            && git push

        ${_kubectl} create ns cluster-room101-a7d-mc
        ${_kubectl} create ns flux-system
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

reset_dns() {
    CURRENT_RECORD=$(dig a k8s.room101-a7d-mc.lab.a7d.dev +short @1.1.1.1)

    if [ "${CURRENT_RECORD}" != "172.25.100.3" ]; then
        log_info "resetting DNS record for MC API"
        RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE}/dns_records" \
            --header 'Content-Type: application/json' \
            -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
            -H "X-Auth-Key: ${CLOUDFLARE_TOKEN}" \
            -H "Content-Type: application/json" \
            | jq -r '.result[] | select((.name=="k8s.room101-a7d-mc.lab.a7d.dev") and (.type=="A"))'.id)

        curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE}/dns_records/${RECORD_ID}" \
        --header 'Content-Type: application/json' \
            -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
            -H "X-Auth-Key: ${CLOUDFLARE_TOKEN}" \
            -H "Content-Type: application/json" \
            --data '{"type":"A","name":"k8s.room101-a7d-mc.lab","content":"172.25.100.3","ttl":60,"proxied":false}'

        until [ `dig a k8s.room101-a7d-mc.lab.a7d.dev +short @1.1.1.1` == "172.25.100.3" ]; do
            log_info "waiting for DNS record to update"
            sleep 10
        done
    else
        log_info "DNS record for MC API is already correct"
    fi
}

check_dns() {
    CURRENT_RECORD=$(dig a k8s.room101-a7d-mc.lab.a7d.dev +short @1.1.1.1)

    log_info "Current DNS record for MC API is ${CURRENT_RECORD}"
}

bootstrap_flux() {
    export _flux="flux --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"

    ${_flux} bootstrap github --owner a7d-corp --repository homelab-clusters-fleet \
    	--branch main --path clusters/bootstrap --secret-name flux-system
}

wait_on_machines() {
    export _kubectl="kubectl --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"

    until ${_kubectl} get server; do
        log_info "waiting for server CRD to be created"
        sleep 10
    done

    until [ `${_kubectl} get server --no-headers=true | wc -l` == 3 ]; do
        log_info "waiting for all servers to be created"
        sleep 10
    done

    log_info "waiting for servers to be powered on"

    ${_kubectl} wait --for=jsonpath='{.status.power}'=on server 203e63cb-a8aa-4bf8-a5b6-333090507777 --timeout=600s
    ${_kubectl} wait --for=jsonpath='{.status.power}'=on server 461b9ad1-3ff0-4bef-8e1e-0dbfc1d8fa43 --timeout=600s
    ${_kubectl} wait --for=jsonpath='{.status.power}'=on server 498eeb6c-76dd-4fb1-9bc4-bb940e8803ff --timeout=600s
}

deploy_mc() {
    log_info "Resetting MC API DNS record"
    reset_dns

    log_info "Deploying MC cluster resources"
    cd $(git rev-parse --show-toplevel)
    sed -i 's/suspend: true/suspend: false/g' clusters/bootstrap/20-talos-cluster.yaml && \
        git add clusters/bootstrap/20-talos-cluster.yaml && \
        git commit -m "resume reconciliation of bootstrap cluster Talos resources" && \
        git push
}

disable_bootstrap_cluster() {
    export _kubectl="kubectl --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"

    for deploy in $(${_kubectl} get deploy -n flux-system -o custom-columns=NAME:.metadata.name --no-headers=true); do
        ${_kubectl} scale deploy $deploy -n flux-system --replicas=0
    done

    ${_kubectl} scale deploy proxmox-operator -n proxmox-operator --replicas=0
}

destroy_qemu() {
    export _kubectl="kubectl --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"
    export _flux="flux --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"

    # stop flux reconciling gitrepo
    ${_flux} suspend ks flux-system -n flux-system

    ${_flux} suspend ks 20-talos-machine-config -n cluster-room101-a7d-mc
    for qemu in $(${_kubectl} get qemu -o custom-columns=NAME:.metadata.name --no-headers=true); do ${_kubectl} delete qemu $qemu ; done
}

redeploy_qemu() {
    export _flux="flux --kubeconfig=$(git rev-parse --show-toplevel)/tmp/bootstrap.kubeconfig"

    # stop flux reconciling gitrepo
    ${_flux} resume ks flux-system -n flux-system

    ${_flux} resume ks 20-talos-machine-config -n cluster-room101-a7d-mc
}

show_help() {
    echo "Creation flags:

-a | --auto             Do all the things
   | --redeploy-mc      Recreate MC cluster resources

-r | --recreate         Recreate bootstrap cluster
   | --dns              Reset DNS record for MC API
   | --check-dns        Get current DNS record for MC API
-f | --flux             Bootstrap flux into recreated cluster
-d | --deploy           Deploy MC Cluster resources
-s | --scale-down       Scale down bootstrap controllers (flux, proxmox)

Machine lifecycle flags:

-q | --qemu             Delete QEMU machines
   | --redeploy-qemu    Redeploy QEMU machines"
}

log_info() {
    echo -e "\nINFO: ${1}\n"
}

parse_args $@
