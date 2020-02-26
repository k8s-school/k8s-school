#!/bin/bash

set -e

ISTIO_VERSION=1.2.5

DIR=$(cd "$(dirname "$0")"; pwd -P)

ISTIO_DIR="$DIR/istio-${ISTIO_VERSION}"

wait_key()
{
  echo "Press 'c' to continue"
  count=0
  while : ; do
	  read -n 1 k <&1
	  if [[ $k = c ]] ; then
		  printf "\nContinuing\n"
		  break
	  else
		  ((count=$count+1))
		  printf "\nIterate for $count times\n"
                  echo "Press 'c' to continue"
	  fi
  done
}

echo "Route all traffic to v1 services, see http://localhost:20001/kiali"
set -x
kubectl apply -f "$ISTIO_DIR"/samples/bookinfo/networking/destination-rule-reviews.yaml
kubectl apply -f "$ISTIO_DIR"/samples/bookinfo/networking/virtual-service-all-v1.yaml
# Example below works fine
# kubectl apply -f "$ISTIO_DIR"/samples/bookinfo/networking/virtual-service-reviews-v3.yaml

set +x

wait_key

echo "Route 50% traffic to v3 services"
set -x
kubectl apply -f "$ISTIO_DIR"/samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml
set +x

wait_key

echo "Clean up"
set -x
kubectl delete -f "$ISTIO_DIR"/samples/bookinfo/networking/virtual-service-all-v1.yaml
set +x

