#!/bin/sh

set -e
set -x

ISTIO_VERSION=1.2.5

DIR=$(cd "$(dirname "$0")"; pwd -P)

ISTIO_DIR="$DIR/istio-${ISTIO_VERSION}"

echo "Create a new namespace called bookinfo and add istio-injection label
"
kubectl create ns bookinfo
kubectl label namespace bookinfo istio-injection=enabled
kubectl get ns --show-labels
kubectl get namespace -L istio-injection
kubectl config set-context $(kubectl config current-context) --namespace=bookinfo

kubectl apply -f "$ISTIO_DIR"/samples/bookinfo/platform/kube/bookinfo.yaml

kubectl --namespace=bookinfo wait --timeout=400s --for=condition=available deploy --all

# Ingress
kubectl apply -f "$ISTIO_DIR"/samples/bookinfo/networking/bookinfo-gateway.yaml
