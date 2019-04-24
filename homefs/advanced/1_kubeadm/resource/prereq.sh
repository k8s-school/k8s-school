#!/bin/sh

set -e

DIR=$(cd "$(dirname "$0")"; pwd -P)
. ./env.sh

apt-get update -q
apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
sudo cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update -q
apt-get install -y --allow-downgrades --allow-change-held-packages \
    kubelet="$KUBEADM_VERSION" kubeadm="$KUBEADM_VERSION" kubectl="$KUBEADM_VERSION"
apt-mark hold kubelet kubeadm kubectl
apt-get install -y docker.io="$DOCKER_VERSION" ipvsadm
apt-get -y autoremove

systemctl enable docker.service