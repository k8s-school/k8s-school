#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

kubectl apply -f $DIR/../15-12-mongo-configmap.yaml
kubectl apply -f $DIR/../15-11-mongo-service.yaml
kubectl apply -f $DIR/15-14-mongo-pvc.yaml

NB_REPLICA=3

kubectl rollout status --timeout=300s statefulset/mongo
kubectl get pods -l app=mongo

echo "Waiting for the $NB_REPLICA members of the mongo replica set to be healthy"
for i in $(seq 60); do
  healthy=$(kubectl exec mongo-0 -c mongodb -- mongosh --quiet \
    --eval 'rs.status().members.filter(m => m.health == 1).length' || echo 0)
  if [ "$healthy" -eq "$NB_REPLICA" ]; then
    break
  fi
  sleep 5
done
kubectl exec mongo-0 -c mongodb -- mongosh --quiet \
  --eval 'rs.status().members.map(m => m.name + " " + m.stateStr)'
if [ "$healthy" -ne "$NB_REPLICA" ]; then
  >&2 echo "ERROR: $healthy healthy members in the replica set, expected $NB_REPLICA"
  exit 1
fi
