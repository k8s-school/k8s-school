#!/bin/bash

# See https://istio.io/docs/tasks/traffic-management/ingress/ingress-control/#determining-the-ingress-ip-and-ports

set -euxo pipefail

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=$(kubectl get nodes kind-worker -o jsonpath='{ .status.addresses[?(@.type=="InternalIP")].address }')
GATEWAY_URL="http://$INGRESS_HOST:$INGRESS_PORT/productpage"

LOG_FILE="/tmp/query.log"
rm -rf "$LOG_FILE"

echo "Sending logs to $LOG_FILE"

# TODO: test siege or fortio
curl -s "${GATEWAY_URL}" | grep -o "<title>.*</title>" >> "$LOG_FILE"
curl  -sIv "${GATEWAY_URL}" >> "$LOG_FILE"

while :;
do echo "====================================" >> "$LOG_FILE"
  sleep 1
  for i in $(seq 1 100); 
  do
    curl -s "$GATEWAY_URL" | grep 'font color' | uniq >> "$LOG_FILE"
    # curl -s -o /dev/null "$GATEWAY_URL"
  done
done
