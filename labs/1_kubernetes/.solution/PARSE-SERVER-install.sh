#/bin/sh

set -e
set -x

kubectl apply -f 17-1-parse.yaml 
kubectl apply -f 17-2-parse-service.yaml 
