#!/usr/bin/env bash

print_help() {
    echo "
# Usage

All flags are required.

--opnsense-address      IP address of hostname of OPNsense firewall.
--api-key               API key to access OPNsense.
--api-secret            API key secret to access OPNsense.
--asn                   Remote AS number of neighbour.
--first-ip              First IP address in range of neighbours.
--last-ip               Last IP address in range of neighbours.
--update-source         OPNsense interface facing remote peer.
--post-description      Text string to add to neighbour description.
"
}

gen_json_payload() {

json_template="'{
  \"neighbor\": {
    \"enabled\": \"1\",
    \"description\": \"${neighbour_ip} (${post_description})\",
    \"address\": \"${neighbour_ip}\",
    \"remoteas\": \"${asn}\",
    \"password\": \"\",
    \"weight\": \"\",
    \"localip\": \"\",
    \"updatesource\": \"${update_source}\",
    \"linklocalinterface\": \"\",
    \"nexthopself\": \"1\",
    \"nexthopselfall\": \"0\",
    \"multihop\": \"0\",
    \"multiprotocol\": \"0\",
    \"rrclient\": \"0\",
    \"bfd\": \"0\",
    \"keepalive\": \"\",
    \"holddown\": \"\",
    \"connecttimer\": \"\",
    \"defaultoriginate\": \"0\",
    \"asoverride\": \"0\",
    \"disable_connected_check\": \"0\",
    \"linkedPrefixlistIn\": \"\",
    \"linkedPrefixlistOut\": \"\",
    \"linkedRoutemapIn\": \"\",
    \"linkedRoutemapOut\": \"\"
  }
}'"

echo $json_template
}

curl_api() {
    curl -k \
        -X POST -H "Content-type: application/json" \
        -d ${json_payload} \
        -u ${api_key}:${api_secret} \
        https://${opnsense_address}/api/quagga/bgp/addNeighbor
    _return=${?}

    if [[ ${_return} -gt 0 ]]; then
        echo "ERR: failed to create BGP neighbour for ${neighbour_ip}"
    else
        echo "INF: created BGP neighbour for ${neighbour_ip}"
    fi
}

main() {
    first_ip_last_octet=$(echo ${first_ip} | rev | cut -d '.' -f1 | rev)
    last_ip_last_octet=$(echo ${last_ip} | rev | cut -d '.' -f1 | rev)
    first_three_octets=$(echo ${first_ip} | cut -d '.' -f1-3)

    for last_octet in `seq $first_ip_last_octet $last_ip_last_octet` ; do
        neighbour_ip="${first_three_octets}.${last_octet}"
        json_payload=$(gen_json_payload)

        # post request to opnsense api
        curl_api

        # tidy up
        unset $neighbour_ip
    done
}

SHORT=h
LONG=opnsense-address:,api-key:,api-secret:,asn:,first-ip:,last-ip:,post-description:,update-source:,help
OPTS=$(getopt -n add-bgp-neighbours --options $SHORT --longoptions $LONG -- "$@")

eval set -- "$OPTS"

while :
do
case "$1" in
    --opnsense-address )
    opnsense_address="$2"
    shift 2
    ;;
    --api-key )
    api_key="$2"
    shift 2
    ;;
    --api-secret )
    api_secret="$2"
    shift 2
    ;;
    --asn )
    asn="$2"
    shift 2
    ;;
    --first-ip )
    first_ip="$2"
    shift 2
    ;;
    --last-ip )
    last_ip="$2"
    shift 2
    ;;
    --update-source )
    update_source="$2"
    shift 2
    ;;
    --post-description )
    post_description="$2"
    shift 2
    ;;
    -h | --help)
    print_help
    exit 2
    ;;
    --)
    shift;
    break
    ;;
    *)
    echo "Unexpected option: $1"
    ;;
esac
done

main
