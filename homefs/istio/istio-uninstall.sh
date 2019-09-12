#!/bin/sh

set -e
set -x

ISTIO_VERSION=1.2.4

echo "Delete both istio and istio-init Helm charts"
helm delete --purge istio
helm delete --purge istio-init

echo "Delete CRDs and Istio Configuration"
kubectl delete -f istio-"$ISTIO_VERSION"/install/kubernetes/helm/istio-init/files

echo "Delete Tiller (Helm server) deployment"
kubectl -n kube-system delete deploy tiller-deploy
