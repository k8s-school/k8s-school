#!/bin/sh

# RBAC
# see "kubernetes in action" p362

DIR=$(cd "$(dirname "$0")"; pwd -P)

# Create namespaces 'foo' and 'bar'
kubectl create ns foo
kubectl create ns bar

# # Create busybox pod named 'shell' in ns 'bar'
# kubectl run -it --rm --generator=run-pod/v1 --image-pull-policy='Never' \
#   shell --image=busybox -n bar sleep 3600

# # Create busybox pod named 'shell' in ns 'foo'
# kubectl run -it --rm --generator=run-pod/v1 --image-pull-policy='Never' \
#   shell --image=busybox -n foo sleep 3600

# # Check RBAC is enabled:
# # inside foo:shell, curl k8s api server 
# # at URL <API_SERVER>:<PORT>/api/v1/namespaces/foo/services
# kubectl exec -it -n foo shell curl localhost:8080/api/v1/namespaces/foo/services

# Study and create role manifest/service-reader.yaml in ns 'foo'
kubectl apply -f $DIR/manifest/service-reader.yaml

# Create role service-reader.yaml in ns 'bar'
# Use 'kubectl create role' command instead of yaml
kubectl create role service-reader --verb=get --verb=list --resource=services -n bar

# Create a rolebindind 'service-reader-rb' to bind role foo:service-reader
# to sa (i.e. serviceaccount) foo:default
kubectl create rolebinding service-reader-rb --role=service-reader --serviceaccount=foo:default -n foo

# List service in ns 'foo' from foo:shell
kubectl exec -it -n foo shell curl localhost:8080/api/v1/namespaces/foo/services

# Use the patch command to add bind foo:service-reader to sa bar.default
# TODO fix command
kubectl patch rolebindings.rbac.authorization.k8s.io -n foo service-reader-rb --type='json' \
    -p='[{"op": "add", "path": "/subjects", "value":[{"kind":"ServiceAccount","name":"default","namespace": "bar"}]}]'

# List service in ns 'foo' from bar:shell
kubectl exec -it -n bar shell curl localhost:8080/api/v1/namespaces/foo/services
