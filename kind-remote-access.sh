#!/bin/sh

# Open access to a remote kind/k8s cluster

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

KIND_SERVER="clrqserv01.in2p3.fr"

KUBECONFIG="$HOME/src/k8s-school/homefs/.kube/config"

scp -r "$KIND_SERVER":~/.kube/kind-config-kind "$KUBECONFIG"
PORT=$(grep server "$KUBECONFIG" | cut -d':' -f 4)
# Optional: retrieve certs
# scp -r "$KIND_SERVER":~/src/k8s-school/homefs/.certs ~/src/k8s-school/homefs/
ssh -nNT -L "$PORT":localhost:"$PORT" clrqserv01.in2p3.fr
