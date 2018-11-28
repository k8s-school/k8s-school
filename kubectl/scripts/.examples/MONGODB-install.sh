#/bin/sh

set -e
set -x

kubectl apply -f 13-12-mongo-configmap.yaml
kubectl apply -f 13-11-mongo-service.yaml 
kubectl apply -f 13-13-mongo.yaml 
