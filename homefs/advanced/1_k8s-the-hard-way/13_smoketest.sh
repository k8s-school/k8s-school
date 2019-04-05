#!/bin/sh

set -e
set -x

# Smoke Test

## Data Encryption


# Create a generic secret:
kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"

# Print a hexdump of the `kubernetes-the-hard-way` secret stored in etcd:

gcloud compute ssh controller-0 \
  --command "sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"

# The etcd key should be prefixed with `k8s:enc:aescbc:v1:key1`, which indicates the `aescbc` provider was used to encrypt the data with the `key1` encryption key.

## Deployments

kubectl run nginx --image=nginx

kubectl get pods -l run=nginx

### Port Forwarding

POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:80 &
curl --head http://127.0.0.1:8080


### Logs

kubectl logs $POD_NAME

### Exec

kubectl exec -ti $POD_NAME -- nginx -v

## Services

kubectl expose deployment nginx --port 80 --type NodePort
NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')

# Create a firewall rule that allows remote access to the `nginx` node port:
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-nginx-service \
  --allow=tcp:${NODE_PORT} \
  --network kubernetes-the-hard-way

# Retrieve the external IP address of a worker instance:

EXTERNAL_IP=$(gcloud compute instances describe worker-0 \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

# Make an HTTP request using the external IP address and the `nginx` node port:
curl -I http://${EXTERNAL_IP}:${NODE_PORT}

## Untrusted Workloads

# Create the `untrusted` pod:

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: untrusted
  annotations:
    io.kubernetes.cri.untrusted-workload: "true"
spec:
  containers:
    - name: webserver
      image: gcr.io/hightowerlabs/helloworld:2.0.0
EOF

### Verification

# Verify the `untrusted` pod is running:

kubectl get pods -o wide
INSTANCE_NAME=$(kubectl get pod untrusted --output=jsonpath='{.spec.nodeName}')
gcloud compute ssh ${INSTANCE_NAME} --command "sudo runsc --root  /run/containerd/runsc/k8s.io list"

echo  "TODO: finish"
exit 1

# Get the ID of the `untrusted` pod:
POD_ID=$(sudo crictl -r unix:///var/run/containerd/containerd.sock \
  pods --name untrusted -q)

# Get the ID of the `webserver` container running in the `untrusted` pod:

CONTAINER_ID=$(sudo crictl -r unix:///var/run/containerd/containerd.sock \
  ps -p ${POD_ID} -q)

# Use the gVisor `runsc` command to display the processes running inside the `webserver` container:

sudo runsc --root /run/containerd/runsc/k8s.io ps ${CONTAINER_ID}