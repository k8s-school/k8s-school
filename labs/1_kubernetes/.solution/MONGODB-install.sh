#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

kubectl apply -f $DIR/../15-12-mongo-configmap.yaml
kubectl apply -f $DIR/../15-11-mongo-service.yaml 
kubectl apply -f $DIR/15-14-mongo-pvc.yaml 

NB_REPLICA=3

for ((i=0; i<$NB_REPLICA; i++))
do
  kubectl wait --for=condition=ready pod --timeout=60s -l statefulset.kubernetes.io/pod-name=mongo-$i
done

kubectl get pods -l app=mongo
sleep 5
