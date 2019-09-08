#!/bin/sh

set -e
set -x

ISTIO_VERSION=1.2.4

echo "Create a new namespace called bookinfo and add istio-injection label
"
kubectl create ns bookinfo
kubectl label namespace bookinfo istio-injection=enabled
kubectl get ns --show-labels
kubectl get namespace -L istio-injection
kubectl config set-context $(kubectl config current-context) --namespace=bookinfo

kubectl apply -f istio-"$ISTIO_VERSION"/samples/bookinfo/platform/kube/bookinfo.yaml

kubectl --namespace=bookinfo wait --timeout=400s --for=condition=available deploy --all
