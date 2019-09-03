# k8s-school

[WWW](https://www.k8s-school.fr)

![K8s-school Logo](http://k8s-school.fr/images/logo.svg "K8s-school, expertise et formation Kubernetes"")


# Course

All materials are [here](https://drive.google.com/open?id=0B-VJpOQeezDjZktuTnlEMEpGMUU)

Free kubernetes icons: https://github.com/octo-technology/kubernetes-icons

# Solutions for installing kubernetes

https://kubernetes.io/docs/setup/pick-right-solution/#bare-metal

# Exercices

## Pre-requisites

### Set up local machine

- Ubuntu LTS is recommended
- 8 cores, 16 GB RAM, 30GB for the partition hosting docker entities (images, volumes, containers, etc). Use `df` command as below to find its size.
```shell
sudo df –sh /var/lib/docker # or /var/snap/docker/common/var-lib-docker/
```
- Internet access without proxy
- `sudo` access
- Install dependencies below:
```shell
sudo apt-get install curl docker.io git vim

# then add current user to docker group and restart gnome session
sudo vim /etc/group
```
However, depending on your linux distribution version, you might have to upgrade to docker-ce:
https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1


### Install kind cluster


Use automated procedure below (sudo access required)

```shell
git clone https://github.com/fjammes/kind-travis-ci
cd kind-travis-ci
./kind/k8s-create.sh
```
or follow official instructions at: https://github.com/kubernetes-sigs/kind

Then configure the container used during the school (i.e. Kubernetes client and tooling):
```shell
# Get configuration file from kind cluster
SCHOOL="$HOME/src/k8s-school"
mkdir -p "$SCHOOL"
git clone https://gitlab.com/fjammes/k8s-school "$SCHOOL"
mkdir -p "$SCHOOL/homefs/.kube"
export KUBECONFIG=$(kind get kubeconfig-path --name="kind")
cp "$KUBECONFIG" "$SCHOOL/homefs/.kube/config"

# Run kubectl client inside container and play with k8s
cd "$SCHOOL"
./run-kubectl.sh
kubectl get nodes
```

## Play with examples

```shell
# Retrieve examples
./clone-book-examples.sh
# Play with kubectl and yaml files :-)
```

## Install 2 example apps
https://github.com/kubernetes/examples/blob/master/README.md

## Install Prometheus

See [here](https://gitlab.com/fjammes/k8s-advanced/tree/master/B_prometheus)
