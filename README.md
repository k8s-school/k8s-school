# k8s-school

# Course

All materials are [here](https://drive.google.com/open?id=0B-VJpOQeezDjZktuTnlEMEpGMUU)

# Solutions for installing kubernetes

https://kubernetes.io/docs/setup/pick-right-solution/#bare-metal

# Exercices

## Pre-requisites

### Set up local machine

Depending on your linux distribution version, you might have to upgrade to docker-ce:
https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1

```shell
sudo apt-get install curl docker.io git vim

# then add current user to docker group and restart gnome session
sudo vim /etc/group

# Install dind cluster
wget https://cdn.rawgit.com/kubernetes-sigs/kubeadm-dind-cluster/master/fixed/dind-cluster-v1.10.sh
chmod +x dind-cluster-v1.10.sh
./dind-cluster-v1.10.sh up

# Test directly on host
export PATH="$HOME/.kubeadm-dind-cluster:$PATH"
kubectl get nodes

# Get configuration file from dind cluster
docker cp kube-master:/etc/kubernetes/admin.conf  ~/src/k8s-school/dot-kube/dindconfig
ln -sf ~/src/k8s-school/dot-kube/dindconfig ~/src/k8s-school/dot-kube/config

# Run kubectl client inside container and play with k8s
./run-kubectl.sh
```

## Play with dashboard

http://localhost:8080/api/v1/namespaces/kube-system/services/kubernetes-dashboard:/proxy

## Play with examples

```shell
git clone https://github.com/fjammes/k8s-school
cd k8s-school
# Retrieve examples
./kubectl/scripts/clone-book-examples.sh
# Run kubectl client in a Docker container
./run-kubectl.sh
cd ./scripts/
# Play with kubectl and yaml files :-)
```

## Install 2 example apps
https://github.com/kubernetes/examples/blob/master/README.md

## Install Prometheus

See [here](./monitoring)
