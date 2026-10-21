#!/bin/bash

# Rolling update of the mongo StatefulSet to a new MongoDB patch version
# See https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets

set -euxo pipefail

SF="mongo"
NB_REPLICA=3
IMAGE="docker.io/library/mongo:7.0.45"
RS="mongodb://mongo-0.mongo:27017/test?replicaSet=rs0"

kubectl patch statefulset "$SF" -p '{"spec":{"updateStrategy":{"type":"RollingUpdate"}}}'

# Pods are updated one at a time, in reverse ordinal order: mongo-2, mongo-1, then mongo-0
kubectl patch statefulset "$SF" --type='json' -p="[
    {\"op\": \"replace\", \"path\": \"/spec/template/spec/containers/0/image\", \"value\":\"$IMAGE\"},
    {\"op\": \"replace\", \"path\": \"/spec/template/spec/containers/1/image\", \"value\":\"$IMAGE\"}]"

kubectl rollout status --watch --timeout=600s statefulset/"$SF"
kubectl get pods -l app=mongo -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.containers[0].image}{"\n"}{end}'

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

# The data survived the update: it lives in the PVCs, not in the pods
for i in $(seq 0 $((NB_REPLICA-1))); do
  kubectl exec mongo-$i -c mongodb -- mongosh --quiet --eval 'db.version()'
done
count=$(kubectl exec mongo-0 -c mongodb -- mongosh --quiet "$RS" --eval "db.restaurants.countDocuments()")
echo "$count restaurants after the update"
if [ "$count" -eq 0 ]; then
  >&2 echo "ERROR: no data after the update"
  exit 1
fi
