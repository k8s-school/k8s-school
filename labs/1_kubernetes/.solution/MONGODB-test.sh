#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

# Only the primary accepts writes: connect to the replica set, not to a pod
RS="mongodb://mongo-0.mongo:27017/test?replicaSet=rs0"

curl -sO https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json
kubectl exec -i mongo-0 -c mongodb -- mongoimport --uri "$RS" --collection restaurants --drop < primer-dataset.json
count=$(kubectl exec mongo-0 -c mongodb -- mongosh --quiet "$RS" --eval "db.restaurants.countDocuments()")
echo "$count restaurants"
if [ "$count" -ne "$(wc -l < primer-dataset.json)" ]; then
  >&2 echo "ERROR: $count documents imported"
  exit 1
fi
kubectl exec mongo-0 -c mongodb -- mongosh --quiet "$RS" --eval "db.restaurants.findOne()"
