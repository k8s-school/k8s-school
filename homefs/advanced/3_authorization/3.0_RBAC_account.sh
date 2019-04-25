#!/bin/sh

set -e
set -x

# RBAC user
# see Use case 1 in
# https://docs.bitnami.com/kubernetes/how-to/configure-rbac-in-your-kubernetes-cluster/#use-case-1-create-user-with-limited-namespace-access 

DIR=$(cd "$(dirname "$0")"; pwd -P)

kubectl delete ns -l "RBAC=user"

# Create namespace 'foo' in yaml, with label "RBAC=clusterrole"
kubectl create ns office
kubectl label ns office "RBAC=user"

CERT_DIR="$HOME/.certs"
mkdir -p "$CERT_DIR"

# Follow "Use case 1" with ns foo instead of office
openssl genrsa -out "$CERT_DIR/employee.key" 2048
openssl req -new -key "$CERT_DIR/employee.key" -out "$CERT_DIR/employee.csr" \
    -subj "/CN=employee/O=bitnami"

# Get key from dind cluster:
# docker cp kube-master:/etc/kubernetes/pki/ca.crt ~/src/k8s-school/homefs/.certs
# docker cp kube-master:/etc/kubernetes/pki/ca.key ~/src/k8s-school/homefs/.certs
openssl x509 -req -in "$CERT_DIR/employee.csr" -CA "$CERT_DIR/ca.crt" \
    -CAkey "$CERT_DIR/ca.key" -CAcreateserial -out "$CERT_DIR/employee.crt" -days 500

kubectl config set-credentials employee --client-certificate="$CERT_DIR/employee.crt" \
    --client-key="$CERT_DIR/employee.key"
kubectl config set-context employee-context --cluster=kubernetes --namespace=office \
    --user=employee

kubectl --context=employee-context get pods || \
    >&2 echo "ERROR to get pods"

kubectl create -f "$DIR/manifest/role-deployment-manager.yaml"

kubectl create -f "$DIR/manifest/rolebinding-deployment-manager.yaml"

kubectl --context=employee-context run --image bitnami/dokuwiki mydokuwiki
kubectl --context=employee-context get pods

kubectl --context=employee-context get pods --namespace=default || \
    >&2 echo "ERROR to get pods"
