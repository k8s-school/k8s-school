---
title: 'Kubernetes easy install with Kubeadm'
date: 2020-01-27T14:15:26+10:00
draft: false
weight: 1
tags: ["kubernetes", "kubeadm", "kubectl", "installation", "weave", "containerd", "ubuntu"]
---

**Auteur:** Fabrice JAMMES ([LinkedIn](https://www.linkedin.com/in/fabrice-jammes-5b29b042/)).
**Date:** Jan 27, 2020 · 10 min read


This article explains how to install Kubernetes with [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm/), the **official Kubernetes installer**. It is inspired by the [official documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/), while declining it for Ubuntu and simplifying it.

It has been successfully tested with Kubernetes 1.21.0

## Pre-requisites: Infrastructure

- One or more machines running Ubuntu LTS, with administrator access ( sudo)
- 2 GB or more of RAM per machine
- 2 or more processors on the master node
- Full network connectivity between all machines in the cluster

The ['size-of-master-and-master-components' documentation](https://kubernetes.io/docs/setup/best-practices/cluster-large/#size-of-master-and-master-components) define some guidelines on how to size your masters nodes depending on the total number of your Kubernetes nodes.

## Pre-requisites: System

### Install containerd

`containerd` is a lightweight `runtime` for Linux containers. It is a reliable project, validated by the `Cloud-Native Computing Foundation`, as you can see on the [CNCF landscape web page](https://landscape.cncf.io/selected=containerd). The installation of containerd is required on all of your machines. Indeed, this is the basic brick that will allow Kubernetes to run and manage the containers. Copy and paste the code below in a script and execute it on each machine.

```bash
#!/bin/bash

set -euxo pipefail

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Install containerd
## Set up the repository
### Install packages to allow apt to use a repository over HTTPS
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

### Add Docker apt repository.
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

## Install containerd
sudo apt-get update
sudo apt-get install -y containerd.io

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
```

For more information regarding the installation of containerd, please check the [official documentation](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd).

### Install kubeadm and its friends: kubelet and kubectl

* `kubeadm` is the official Kubernetes installer, it must be run as `root` on each nodes of your Kubernetes cluster.
* `kubelet` is the daemon in charge of running and managing the containers on every nodes controlled by Kubernetes. It must be available on all the nodes of the cluster, including the master nodes because it also manages the containers in charge of the Kubernetes system components. It uses the [CRI specification](https://developer.ibm.com/blogs/kube-cri-overview/) (Container Runtime Interface) to communicate with the local container execution engine, in our example `containerd`.
* `kubectl` is the Kubernetes client, install it on the machine that will allow you to control your Kubernetes cluster.
As seen above, we recommend that you copy and paste the code below into a script and execute it on each machine.

```bash
#!/bin/bash

set -euxo pipefail

sudo mkdir -p /etc/apt/keyrings
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg

K8S_VERSION="v1.29"
curl -fsSL https://pkgs.k8s.io/core:/stable:/"$K8S_VERSION"/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/'"$K8S_VERSION"'/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list


sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl ipvsadm
sudo apt-mark hold kubelet kubeadm kubectl
```

Please note that the script prevents updates to `kubeadm`, `kubectl`, and `kubelet` which could be caused by the installation of security updates with `apt-get` commands.

## Create the Kubernetes cluster

On your master node, run the following command:
```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

Here is what will appear on your console, in the last lines of standard output:

```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  /docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

There are **three very important instructions** here:

- how to configure `kubectl`, the Kubernetes client. In our example we will use the Kubernetes master node as a client, on which we will therefore issue the commands below:
```bash
# Connect with your regular user account, and not with `root` account
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
- installing a network plugin, here we choose a popular one: `calico`. Just run the command below on your Kubernetes client, which we just configured. Note that in our example it is also the master Kubernetes:
```shell
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/custom-resources.yaml -O
kubectl create -f custom-resources.yaml
```
- the command to execute on all your other nodes so that they join the Kubernetes cluster:
```shell
sudo kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

`<control-plane-host>:<control-plane-port>` contains the DNS name or IP and port of the Kubernetes master. `<token>` is the token, whose lifetime is limited, which allows the current node to identify itself to the master. Finally, `<hash>` allows the current node to ensure the authenticity of the master.

{{% notice note %}}
It is not recommended to run user workload on Kubernetes master node(s) for security reason. That's why we recommend to use dedicated master node(s) for running Kubernetes system components.
{{% /notice %}}


## Check that everything works

The following command checks that your Kubernetes cluster is up and running:

```shell
kubectl cluster-info                                                                                                                                                        ✔  10376  09:19:37
Kubernetes master is running at https://127.0.0.1:32903
KubeDNS is running at https://127.0.0.1:32903/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

The command below list all nodes:
```shell
kubectl get nodes
```

Finally, installing Kubernetes with `kubeadm` is rather simple, isn't it :-).

## Remove the cluster
The [official documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down) describes all the operations required to delete your cluster. If you have created your machines in a Cloud, an equivalent and much simpler solution is of course to delete all of them, and then recreate them in their initial state.

## Automate installation

Here is a sample script to automate this process: https://github.com/k8s-school/k8s-advanced/tree/master/0_kubeadm . To learn more, you can contact us and register to one of our [training courses](https://k8s-school.fr/formations-kubernetes).
