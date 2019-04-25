#!/bin/sh

set -e
set -x

# RBAC user
# see Use case 1 in
# https://docs.bitnami.com/kubernetes/how-to/configure-rbac-in-your-kubernetes-cluster/#use-case-1-create-user-with-limited-namespace-access 

DIR=$(cd "$(dirname "$0")"; pwd -P)

# Use context 'kubernetes-admin@kubernetes' and delete ns,pv with label "RBAC=user"
kubectl config use-context kubernetes-admin@kubernetes
kubectl delete pv,clusterrolebinding,ns -l "RBAC=user"

# Create namespace 'foo' in yaml, with label "RBAC=clusterrole"
kubectl create ns office
kubectl label ns office "RBAC=user"

CERT_DIR="$HOME/.certs"
mkdir -p "$CERT_DIR"

# Follow "Use case 1" with ns foo instead of office
# in certificate subject CN is the use name and O the group
openssl genrsa -out "$CERT_DIR/employee.key" 2048
openssl req -new -key "$CERT_DIR/employee.key" -out "$CERT_DIR/employee.csr" \
    -subj "/CN=employee/O=afnic"

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

# Use 'apply' instead of 'create' to create 
# 'role-deployment-manager' and 'rolebinding-deployment-manager'
kubectl apply -f "$DIR/manifest/role-deployment-manager.yaml"

kubectl apply -f "$DIR/manifest/rolebinding-deployment-manager.yaml"

kubectl --context=employee-context run --generator=run-pod/v1 --image bitnami/dokuwiki mydokuwiki
kubectl --context=employee-context get pods

kubectl --context=employee-context get pods --namespace=default || \
    >&2 echo "ERROR to get pods"

# With employee user, try to run a shell in a pod in ns 'office'
kubectl --context=employee-context run --generator=run-pod/v1 -it --image=busybox shell sh || \
    >&2 echo "ERROR to start shell"

# Create a local PersistentVolume on kube-node-1:/data/disk2
# with label "RBAC=user"
# see https://kubernetes.io/docs/concepts/storage/volumes/#local
# WARN: Directory kube-node-1:/data/disk2, must exist 
cat <<EOF >/tmp/task-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv
  labels:
    RBAC: user
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /data/disk2
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - kube-node-1
EOF
kubectl apply -f "/tmp/task-pv.yaml"

# With employee user, create a PersistentVolumeClaim which use pv-1 in ns 'foo'
# See https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolumeclaim
kubectl --context=employee-context apply -f "$DIR/manifest/pvc.yaml" || 
    >&2 echo "ERROR to create pvc"

# Edit role-deployment-manager.yaml to enable pvc management
kubectl apply -f "$DIR/manifest/role-deployment-manager-pvc.yaml"

# Use context employee-context
kubectl config use-context employee-context

# Try again to create a PersistentVolumeClaim which use pv-1 in ns 'foo'
kubectl --context=employee-context apply -f "$DIR/manifest/pvc.yaml"

# Launch the nginx pod which attach the pvc
kubectl apply -f https://k8s.io/examples/pods/storage/pv-pod.yaml

# Wait for office:task-pv-pod to be in running state
while true
do
    sleep 2
    STATUS=$(kubectl get pods -n office task-pv-pod -o jsonpath="{.status.phase}")
    if [ "$STATUS" = "Running" ]; then
        break
    fi
done

# Launch a command in task-pv-pod
kubectl exec -it task-pv-pod echo "SUCCESS in lauching command in task-pv-pod"

# Switch back to context kubernetes-admin@kubernetes
kubectl config use-context kubernetes-admin@kubernetes

# Try to get pv using 'employee-context'
kubectl --context=employee-context get pv || 
    >&2 echo "ERROR to get pv"

# Create a 'clusterrolebinding' between clusterrole=pv-reader and group=afnic
kubectl create clusterrolebinding pv-reader-afnic --clusterrole=pv-reader --group=afnic
kubectl label clusterrolebinding pv-reader-afnic "RBAC=user"

# Try to get pv using 'employee-context'
kubectl --context=employee-context get pv