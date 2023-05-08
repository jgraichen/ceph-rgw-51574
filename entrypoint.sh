#!/bin/bash

set -e

IPV4_REGEXP='[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
IPV4_NETWORK_REGEXP="$IPV4_REGEXP/[0-9]\\{1,2\\}"

function get_ip {
  local nic=$1
  if is_available ip; then
    ip -4 -o a s "$nic" | grep "scope global" | awk '{ sub ("/..", "", $4); print $4 }' || true
  else
    grep -o "$IPV4_REGEXP" /proc/net/fib_trie | grep -vEw "^127|255$|0$" | head -1
  fi
}

function get_network {
  local nic=$1
  if is_available ip; then
    ip -4 route show dev "$nic" | grep proto | awk '{ print $1 }' | grep -v default | grep "/" || true
  else
    grep -o "$IPV4_NETWORK_REGEXP" /proc/net/fib_trie | grep -vE "^127|^0" | head -1
  fi
}

nic_more_traffic=0
nic_more_traffic_actual=$(grep -vE "lo:|face|Inter" /proc/net/dev | sort -n -k 2 | tail -1 | awk '{ sub (":", "", $1); print $1 }')
nic_more_traffic=${CEPH_NIC:=${nic_more_traffic_actual}}

MON_IP=$(get_ip "${nic_more_traffic}")
CEPH_PUBLIC_NETWORK=$(get_network "${nic_more_traffic}")

echo "MON_IP: $MON_IP"
echo "CEPH_PUBLIC_NETWORK: $CEPH_PUBLIC_NETWORK"

export MON_IP
export CEPH_PUBLIC_NETWORK

DAEMON_OPTS="--default-log-to-file=true"
export DAEMON_OPTS

# Write logs in demo setup; otherwise we will not see any output from RGW
sed -i "s/default-log-to-file=false/default-log-to-file=true/" /opt/ceph-container/bin/demo
# sed -i "s/default-log-to-stderr=true/default-log-to-stderr=false/" /opt/ceph-container/bin/demo

exec /opt/ceph-container/bin/demo
