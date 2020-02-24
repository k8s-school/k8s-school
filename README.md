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

# then add current user to docker group and restart gnome session
sudo usermod -a -G docker <USER>
```
However, depending on your linux distribution version, you might have to upgrade to docker-ce:
https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1


### Install kind cluster

Use automated procedure below (sudo access required)

```shell
git clone https://github.com/k8s-school/kind-travis-ci
cd kind-travis-ci
./kind/k8s-create.sh
```
or follow official instructions at: https://github.com/kubernetes-sigs/kind

Then configure the container used during the school (i.e. Kubernetes client and tooling):
```shell
# Run k8s toolbox container and play with k8s
mkdir $HOME/k8s-school/homefs && cd $HOME/k8s-school
curl -lO https://raw.githubusercontent.com/k8s-school/k8s-toolbox/master/toolbox.sh
chmod +x toolbox.sh
./toolbox.sh
kubectl get nodes
```

## Play with examples

```shell
# Retrieve examples by running below script from inside [kubectl] container
clone-school.sh
# Play with kubectl and yaml files :-)
```

## Install 2 example apps
https://github.com/kubernetes/examples/blob/master/README.md

## Install Prometheus

See [here](https://gitlab.com/fjammes/k8s-advanced/tree/master/B_prometheus)

# Additional information

## Free kubernetes icons

* https://github.com/kubernetes/community/tree/master/icons
* https://www.k8s-school.fr/resources/blog/3-k8s-official-icons/

## Solutions for installing kubernetes

https://kubernetes.io/docs/setup/pick-right-solution/#bare-metal
