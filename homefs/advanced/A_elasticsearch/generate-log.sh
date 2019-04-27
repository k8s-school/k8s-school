#!/bin/sh

set -e

# TODO delete nginw with label
kubectl delete pod,service -l "app=nginx" -n logging
kubectl run nginx --generator=run-pod/v1 --image=nginx -n logging
kubectl label pod -n logging nginx "app=nginx"
kubectl create service clusterip -n logging nginx --tcp 80
kubectl label service -n logging nginx "app=nginx"

# Wait for logging:nginx to be in running state
while true
do
    sleep 2
    STATUS=$(kubectl get pods -n logging nginx -o jsonpath="{.status.phase}")
    if [ "$STATUS" = "Running" ]; then
        break
    fi
done

while true; do curl localhost:8081; sleep 2; done
