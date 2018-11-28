#/bin/sh

set -e
set -x

kubectl apply -f 14-1-parse.yaml 
kubectl apply -f 14-2-parse-service.yaml 
