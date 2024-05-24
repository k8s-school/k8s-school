set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

# Cleaning up
"$DIR"/cleanup-default-ns.sh

# Deploying a kubernetes cluster
#
kubectl get componentstatuses
kubectl get nodes
kubectl get deployments --namespace=kube-system kube-dns
kubectl get service --namespace=kube-system kube-dns
kubectl get svc --namespace=kube-system kubernetes-dashboard
kubectl get services --namespace=kube-system kubernetes-dashboard
kubectl get deployments --namespace=kube-system kubernetes-dashboard

# Common kubectl commands
#
# See https://kubernetes.io/docs/user-guide/kubectl-cheatsheet/
# kubectl run kuard --image=gcr.io/kuar-demo/kuard-adm64:1
# kubectl get pods kuard-xxxx -o jsonpath --template={.status.podIP}
# kubectl describe <resource-name> <obj-name>

# Object management
# kubectl apply -f obj.yaml
# kubectl edit <resource-name> <obj-name>
# kubectl delete -f obj.yaml
# kubectl delete <resource-name> <obj-name>

# Label
# kubectl label pods bar color=red
# kubectl label pods bar --overwrite color=green
# kubectl label pods bar -color
# Debug
# kubectl logs <pod-name>
# kubectl exec -it <podY-name> -- bash
# kubectl cp <pod-name>:/path/to/remote/file /path/to/local/file

# Pods
#
kubectl run kuard --image=gcr.io/kuar-demo/kuard-adm64:1
kubectl get pods
kubectl delete deployments/kuard
kubectl apply -f  5-1-kuard-pod.yaml
kubectl get pods
kubectl describe pods kuard
# Port forwarding host_port:pod-port
sleep 5
kubectl port-forward kuard 8081:8080
# On host go to http://localhost:8081
# Logs
kubectl logs -f kuard
# Run commands
kubectl exec kuard data
kubectl exec -it kuard ash
# Health check
kubectl apply -f  5-2-kuard-pod-health.yaml
# ...
# Volume
kubectl apply -f  5-5-kuard-pod-vol.yaml
docker exec -- kube-node-1 ls -rtla /var/lib/kuard
# All together
# Exercice: check if it works and eventually fix it
kubectl apply -f  5-6-kuard-pod-full.yaml
kubectl delete pods/kuard
kubectl delete -f  5-1-kuard-pod.yaml

# Label & Annotations
#
kubectl run alpaca-prod \
    --image=gcr.io/kuar-demo/kuard-amd64:1 \
    --replicas=2 \
    --labels="ver=1,app=alpaca,env=prod"
kubectl run alpaca-test \
    --image=gcr.io/kuar-demo/kuard-amd64:1 \
    --replicas=1 \
    --labels="ver=2,app=alpaca,env=test"
kubectl run bandicoot-prod \
    --image=gcr.io/kuar-demo/kuard-amd64:1 \
    --replicas=2 \
    --labels="ver=2,app=bandicoot,env=prod"
kubectl run bandicoot-test \
    --image=gcr.io/kuar-demo/kuard-amd64:1 \
    --replicas=1 \
    --labels="ver=2,app=bandicoot,env=staging"
kubectl get deployment --show-labels
