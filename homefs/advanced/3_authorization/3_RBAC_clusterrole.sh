#!/bin/sh

# RBAC clusterrole
# see "kubernetes in action" p362

DIR=$(cd "$(dirname "$0")"; pwd -P)

# Delete all namespaces, clusterrole with label 'RBAC=role' to make current script idempotent
kubectl delete ns -l RBAC=clusterrole
kubectl delete clusterrole -l RBAC=clusterrole

# Create namespace 'foo' in yaml, with label "RBAC=clusterrole"
sudo cat <<EOF >/tmp/ns_foo.yaml
kind: Namespace
metadata:
  name: foo
  label:
    RBAC: clusterrole
EOF
kubectl apply -f "/tmp/ns_foo.yaml"

# Create a local persistent volume on kube-node-1:/data/disk1
# with label "RBAC=clusterrole"
# see https://kubernetes.io/docs/concepts/storage/volumes/#local
sudo cat <<EOF >/tmp/pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-1
  label:
    RBAC: clusterrole
spec:
  capacity:
    storage: 100Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: /data/disk1
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - kube-node-1
EOF
kubectl apply -f "/tmp/pv.yaml"

# Create clusterrole 'pv-reader' which can get and list resource 'persistentvolumes'
kubectl create clusterrole pv-reader --verb=get,list --resource=persistentvolumes

# Add label "RBAC=clusterrole"
kubectl label clusterrole pv-reader "RBAC=clusterrole"

# Create pod using image 'luksa/kubectl-proxy', and named 'shell' in ns 'foo'
kubectl run --generator=run-pod/v1 shell --image=luksa/kubectl-proxy -n foo

# Wait for foo:shell to be in running state
while true
do
    sleep 2
    STATUS=$(kubectl get pods -n foo shell -o jsonpath="{.status.phase}")
    if [ "$STATUS" = "Running" ]; then
        break
    fi
done

# List persistentvolumes at the cluster scope, with user "system:serviceaccount:foo:default"
kubectl exec -it -n foo shell curl localhost:8001/api/v1/persistentvolumes

# Create rolebinding 'pv-reader' which can get and list resource 'persistentvolumes'
kubectl create rolebinding pv-test --clusterrole=pv-reader --serviceaccount=foo:default -n foo
