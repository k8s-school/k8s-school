#!/bin/sh

# Open access to a remote kind/k8s cluster

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

KIND_SERVER="clrqserv01.in2p3.fr"

scp -r "$KIND_SERVER":~/.kube/kind-config-kind ~/src/k8s-school/homefs/.kube/config
# Optional: retrieve certs
# scp -r "$KIND_SERVER":~/src/k8s-school/homefs/.certs ~/src/k8s-school/homefs/
ssh -nNT -L 35777:localhost:35777 clrqserv01.in2p3.fr
