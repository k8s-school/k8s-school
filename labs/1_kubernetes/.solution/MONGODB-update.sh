#!/bin/bash

# Rolling update of the mongo StatefulSet to a new MongoDB patch version:
# canary on one pod with a partition, full update, then rollback.
# Follows the "Rolling Update" section of the MongoDB lab page.
# See https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets

set -euxo pipefail

SF="mongo"
NB_REPLICA=3
OLD_VERSION="7.0.43"
NEW_VERSION="7.0.45"
IMAGE="docker.io/library/mongo:$NEW_VERSION"
RS="mongodb://mongo-0.mongo:27017/test?replicaSet=rs0"

wait_healthy() {
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
}

# $@: expected MongoDB versions of mongo-0, mongo-1 and mongo-2
check_versions() {
  local expected=("$@") version
  for i in $(seq 0 $((NB_REPLICA-1))); do
    version=$(kubectl exec mongo-$i -c mongodb -- mongosh --quiet --eval 'db.version()')
    echo "mongo-$i $version"
    if [ "$version" != "${expected[$i]}" ]; then
      >&2 echo "ERROR: mongo-$i runs MongoDB $version, expected ${expected[$i]}"
      exit 1
    fi
  done
}

# The data survives the update: it lives in the PVCs, not in the pods
check_data() {
  count=$(kubectl exec mongo-0 -c mongodb -- mongosh --quiet "$RS" --eval "db.restaurants.countDocuments()")
  echo "$count restaurants"
  if [ "$count" -eq 0 ]; then
    >&2 echo "ERROR: no data after the update"
    exit 1
  fi
}

kubectl get statefulset "$SF" -o jsonpath='{.spec.updateStrategy}{"\n"}'

# Canary on one pod: only the pods with an ordinal >= partition are updated
kubectl patch statefulset "$SF" -p '{"spec":{"updateStrategy":{"rollingUpdate":{"partition":2}}}}'
kubectl set image statefulset/"$SF" mongodb="$IMAGE" init-mongo="$IMAGE"
kubectl rollout status --timeout=600s statefulset/"$SF"
kubectl get pods -l app=mongo -o custom-columns='NAME:.metadata.name,IMAGE:.spec.containers[0].image,REV:.metadata.labels.controller-revision-hash'
wait_healthy
check_versions "$OLD_VERSION" "$OLD_VERSION" "$NEW_VERSION"

# Finish the update: pods are updated one at a time, in reverse ordinal order
kubectl patch statefulset "$SF" -p '{"spec":{"updateStrategy":{"rollingUpdate":{"partition":0}}}}'
kubectl rollout status --timeout=600s statefulset/"$SF"
wait_healthy
check_versions "$NEW_VERSION" "$NEW_VERSION" "$NEW_VERSION"
check_data
kubectl get pvc -o custom-columns=NAME:.metadata.name,VOLUME:.spec.volumeName

# Rollback to the previous ControllerRevision
kubectl rollout history statefulset/"$SF"
kubectl rollout undo statefulset/"$SF"
kubectl rollout status --timeout=600s statefulset/"$SF"
wait_healthy
check_versions "$OLD_VERSION" "$OLD_VERSION" "$OLD_VERSION"
check_data
