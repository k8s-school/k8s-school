#!/bin/sh

set -e
set -x

# RBAC sa
# see "kubernetes in action" p346

DIR=$(cd "$(dirname "$0")"; pwd -P)

kubectl delete sa -l "RBAC=sa"
kubectl delete pod -l "RBAC=sa"

# Create a service account 'foo'
kubectl create serviceaccount foo
kubectl label sa foo "RBAC=sa"

# Describe secret of this sa, and compare it with default sa
FOO_TOKEN=$(kubectl get sa foo -o jsonpath="{.secrets[0].name}")
kubectl describe secrets "$FOO_TOKEN"

# Create a pod using this service account
# use manifest/pod.yaml, and patch it
kubectl patch -f manifest/pod.yaml \
    -p '{"spec":{"serviceAccount":"foo"}}' --local  -o yaml > /tmp/pod.yaml
kubectl apply -f "/tmp/pod.yaml"
kubectl label pod curl-custom-sa "RBAC=sa"

# Wait for pod to be in running state
while true
do
    sleep 2
    STATUS=$(kubectl get pods curl-custom-sa -o jsonpath="{.status.phase}")
    if [ "$STATUS" = "Running" ]; then
        break
    fi
done

# Inspect the token mounted into the pod’s container(s)
kubectl exec -it curl-custom-sa -c main \
    cat /var/run/secrets/kubernetes.io/serviceaccount/token

# Talk to the API server with custom ServiceAccount 'foo'
# (tip: use 'main' container inside 'curl-custom-sa' pod)
kubectl exec -it curl-custom-sa -c main curl localhost:8001/api/v1/pods