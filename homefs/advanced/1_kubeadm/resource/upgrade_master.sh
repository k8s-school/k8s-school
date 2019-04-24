#!/bin/sh

set -e
set -x

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
sudo apt-mark unhold kubelet kubectl
sudo apt-get update -q
sudo apt-get install -y kubelet="$LATEST_KUBEADM" kubectl="$LATEST_KUBEADM"
sudo apt-mark hold kubelet kubectl
