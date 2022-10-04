#!/bin/bash

set -xe

# Write logs in demo setup; otherwise we will not see any output from RGW
sed -i "s/default-log-to-file=false/default-log-to-file=true/" /opt/ceph-container/bin/variables_entrypoint.sh
sed -i "s/default-log-to-stderr=true/default-log-to-stderr=false/" /opt/ceph-container/bin/variables_entrypoint.sh

exec /opt/ceph-container/bin/entrypoint.sh demo
