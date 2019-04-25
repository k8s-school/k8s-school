#!/bin/sh

# RBAC
# see "kubernetes in action" p362

DIR=$(cd "$(dirname "$0")"; pwd -P)

# Create a local persistent volume on kube-node-1
# https://kubernetes.io/docs/concepts/storage/volumes/#local
kubectl apply -f "$DIR/manifest/pv.yaml"

# Create namespaces 'foo' and 'bar'
kubectl create ns foo
kubectl create ns bar