#!/bin/sh

set -e

DIR=$(cd "$(dirname "$0")"; pwd -P)

# Remove debconf messages
export TERM="linux"

# Get latest kubeadm version
sudo apt-get update -q
LATEST_KUBEADM=$(apt-cache madison kubeadm | head -n 1 | cut -d'|' -f2 | xargs)

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
