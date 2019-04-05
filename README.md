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
```

### Install dind cluster

Follow instructions at: https://github.com/kubernetes-sigs/kubeadm-dind-cluster#using-preconfigured-scripts

```shell
# Get configuration file from dind cluster
mkdir -p ~/src/k8s-school/homefs/.kube
docker cp kube-master:/etc/kubernetes/admin.conf ~/src/k8s-school/homefs/.kube/config

# Run kubectl client inside container and play with k8s
git clone https://gitlab.com/fjammes/k8s-school
cd k8s-school
./run-kubectl.sh
kubectl get nodes
```

Play with dashboard.

## Play with examples

```shell
# Retrieve examples
./clone-book-examples.sh
# Play with kubectl and yaml files :-)
```

## Install 2 example apps
https://github.com/kubernetes/examples/blob/master/README.md

## Install Prometheus

See [here](./monitoring)
