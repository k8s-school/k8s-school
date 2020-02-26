set -e
set -x

# Cleaning up
kubectl delete --all deployment
kubectl delete --all service 
kubectl delete --all pod
kubectl delete --all configmap 
kubectl delete --all job 
