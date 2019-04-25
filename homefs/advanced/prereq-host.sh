# Extract certificates for RBAC
docker cp kube-master:/etc/kubernetes/pki/ca.crt ~/src/k8s-school/homefs/.certs
docker cp kube-master:/etc/kubernetes/pki/ca.key ~/src/k8s-school/homefs/.certs

# For RBAC with volumes
docker exec -it -- kube-node-1 mkdir -p /data/disk1/ /data/disk2/ 