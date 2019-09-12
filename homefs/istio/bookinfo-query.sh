#!/bin/sh

set -e

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=$(kubectl get nodes kind-worker -o jsonpath='{ .status.addresses[?(@.type=="InternalIP")].address }')
GATEWAY_URL="http://$INGRESS_HOST:$INGRESS_PORT/productpage"


# TODO: test siege or fortio
curl -s "${GATEWAY_URL}" | grep -o "<title>.*</title>"
curl  -sIv "${GATEWAY_URL}" 

while :;
do echo "===================================="
  sleep 1
  for i in $(seq 1 100); 
  do
    curl -s "$GATEWAY_URL" | grep 'font color' | uniq
    # curl -s -o /dev/null "$GATEWAY_URL"
  done
done
