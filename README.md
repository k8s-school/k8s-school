[<img src="http://k8s-school.fr/images/logo.svg" alt="K8s-school Logo, expertise et formation Kubernetes" height="50" />](https://k8s-school.fr)

# Kubernetes fundamentals course

## Slides and materials

All slides are [on our website](https://k8s-school.fr/pdf)

Check the [Framapad](https://annuel.framapad.org/p/k8s-school?lang=en)

# Set up course platform

## Pre-requisites

### Set up local machine

- Ubuntu LTS is recommended
- 8 cores, 16 GB RAM, 30GB for the partition hosting docker entities (images, volumes, containers, etc). Use `df` command as below to find its size.
```shell
sudo df –sh /var/lib/docker # or /var/snap/docker/common/var-lib-docker/
```
- Internet access **without proxy**
- `sudo` access
- Install dependencies below:
```shell
sudo apt-get install curl docker.io git vim

# then add current user to docker group 
sudo usermod -a -G docker $USER
# command below, or restart gnome session
newgrp docker
```
However, depending on your linux distribution version, you might have to upgrade to docker-ce:
https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1


### Install kind cluster

Use automated procedure below (sudo access required)

```shell
git clone https://github.com/k8s-school/kind-travis-ci
cd kind-travis-ci
./k8s-create.sh -n <cluster-name>
```
or follow official instructions at: https://github.com/kubernetes-sigs/kind

Then validate Kubernetes is up and running
```shell
# Check k8s cluster is up and running
kubectl get nodes

# Launch an ubuntu pod from Docker Hub
kubectl run -it --rm  shell --image=ubuntu --restart=Never -- date

# Launch an other pod from gcr.io
kubectl run shell --image=gcr.io/kuar-demo/kuard-amd64:1 --restart=Never
# Open a shell inside it and exit
kubectl exec -it shell -- ash
exit
kubectl delete pod shell
```

### Configure the k8s-school toolbox (i.e. Kubernetes client and tooling):

Follow official instructions at: https://github.com/k8s-school/k8s-toolbox#installation

## Play with examples

Retrieve k8s-school's examples, demos and exercices by running script below inside `toolbox` container:
```shell
clone-school.sh
# Play with kubectl and yaml files :-)
```

# Additional information

## Free kubernetes icons

* https://github.com/kubernetes/community/tree/master/icons
* https://www.k8s-school.fr/resources/blog/3-k8s-official-icons/

## Creating a single control-plane cluster with kubeadm

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
