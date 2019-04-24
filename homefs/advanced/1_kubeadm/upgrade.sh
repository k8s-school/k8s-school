#!/bin/bash

# Upgrade an up and running k8s cluster

set -e

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/env.sh"

echo "Copy scripts to all nodes"
echo "-------------------------"
parallel --tag -- $SCP --recurse "$DIR/resource" {}:/tmp ::: "$MASTER" $NODES

echo "Backup etcd"
echo "-----------"
$SSH "$MASTER" -- sudo 'sh /tmp/resource/backup_master.sh'

echo "Upgrade master node"
echo "-------------------"
$SSH "$MASTER" -- sudo 'sh /tmp/resource/upgrade_master.sh'

echo "Upgrade worker nodes"
echo "--------------------"
# Drain and upgrade worker nodes, one by one
# Might help
# WORKER_NODES=$(kubectl get nodes --selector="! node-role.kubernetes.io/master" -o name)
for node in $NODES; do
    $SSH "$MASTER" -- kubectl drain "$node" --ignore-daemonsets
    $SSH "$node" -- sh /tmp/resource/upgrade_worker.sh
    $SSH "$MASTER" -- kubectl uncordon "$node"
done

echo "Perform final check"
echo "-------------------"
$SSH "$MASTER" -- kubectl get nodes -o wide