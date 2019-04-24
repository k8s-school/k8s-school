#!/bin/sh

set -e

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/env.sh"

# On whole control plane
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm="$LATEST_KUBEADM"
sudo apt-mark hold kubeadm
kubeadm version

# On master node only
LATEST_K8S="v1.14.1"
sudo kubeadm upgrade plan "$LATEST_K8S"
sudo kubeadm upgrade apply -y "$LATEST_K8S"

# On whole control plane
sudo apt-mark unhold kubelet
sudo apt-get update -q
sudo apt-get install -y kubelet="$LATEST_KUBEADM"
sudo apt-mark hold kubelet

# Required on all nodes, but useful on master only
sudo apt-mark unhold kubectl
sudo apt-get update -q
sudo apt-get install -y kubectl="$LATEST_KUBEADM"
sudo apt-mark hold kubectl

# Drain master node
MASTER_NODES=$(kubectl get nodes --selector="node-role.kubernetes.io/master")
for node in $MASTER_NODES; do
    kubectl drain $node --ignore-daemonsets
done

# Drain worker nodes
WORKER_NODES=$(kubectl get nodes --selector="! node-role.kubernetes.io/master")
for node in $WORKER_NODES; do
    kubectl drain $node
done
