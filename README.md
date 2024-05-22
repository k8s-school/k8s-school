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

### Configure the k8s-toolbox (i.e. Kubernetes client and tooling):

Follow official instructions at: https://github.com/k8s-school/k8s-toolbox

- Use the k8s-toolbox to create a k8s cluster, if it does not yet exists
- Launch interactive k8s-toolbox:

```shell
ktbx desk
```

then validate Kubernetes is up and running
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

## Play with examples

Retrieve k8s-school's examples, demos and exercices by running script below inside `toolbox` container:
```shell
clone-school.sh
# Play with kubectl and yaml files :-)
```

# Additional information

## Kubernetes ecosystem

* [ArgoCD demo](https://github.com/k8s-school/argocd-demo.git)
* [Ingress demo](https://github.com/k8s-school/nginx-controller-example.git)
* [Istio demo](ttps://github.com/k8s-school/istio-example.git)
* [Telepresence demo](https://github.com/k8s-school/telepresence-demo.git)

