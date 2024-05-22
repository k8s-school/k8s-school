---
title: 'Installer Kubernetes simplement avec Kubeadm'
date: 2021-04-22T14:15:26+10:00
draft: false
weight: 1
tags: ["kubernetes", "kubeadm", "kubectl", "installation", "weave", "containerd", "ubuntu"]
---

**Auteur:** Fabrice JAMMES ([LinkedIn](https://www.linkedin.com/in/fabrice-jammes-5b29b042/)).
**Date:** Apr 22, 2021 · 10 min de lecture


Cet article explique comment installer Kubernetes avec [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm/), **l'installeur officiel de Kubernetes**, en quelques lignes.
Il s'inspire de la [documentation officielle](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/), tout en la déclinant pour Ubuntu et en la simplifiant.

Cette documentation a été validé pour `Kubernetes 1.21.0`.

## Pré-requis côté infrastructure

- Une ou plusieurs machines sous Ubuntu LTS, avec accès administrateur (`sudo`)
- 2 Go ou plus de RAM par machine
- 2 processeurs ou plus sur le noeud maître
- Connectivité réseau complète entre toutes les machines du cluster

La [documentation 'size-of-master-and-master-components'](https://kubernetes.io/docs/setup/best-practices/cluster-large/#size-of-master-and-master-components) définit la façon de dimensionner vos nœuds maîtres en fonction du nombre total de nœuds de votre cluster Kubernetes.

## Pré-requis côté système

### Installer containerd

Pour information, `containerd` est un `runtime` léger pour conteneurs Linux, c'est un projet fiable et validé par la `Cloud-Native Computing Foundation`, comme vous pouvez le voir sur la page web du [landscape CNCF](https://landscape.cncf.io/selected=containerd).
L'installation de `containerd` est à réaliser sur l'ensemble de vos machines. En effet, c'est la brique de base qui permettra à Kubernetes de gérer les conteneurs. L'idéal est de copier-coller le code ci-dessous dans un script et de l'exécuter sur chaque machine.

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

Pour plus d'informations concernant l'installation de `containerd`, tous les détails sont dans la [documentation officielle](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd).

### Installer kubeadm et ses acolytes: kubelet et kubectl

* `kubeadm` est l'installeur officiel de Kubernetes, il doit être exécuté en tant qu'administrateur sur chacun des noeuds de votre cluster Kubernetes.
* `kubelet` est le démon en charge d'exécuter et de gérer les conteneurs sur chacun des noeuds pilotés par Kubernetes. Il doit être disponible sur l'ensemble des noeuds du cluster, et également les noeuds maîtres car il gère également les conteneurs en charge des composant système de Kubernetes. Il s'appuie sur la [spécification CRI](https://developer.ibm.com/blogs/kube-cri-overview/) (Container Runtime Interface), pour communiquer avec le moteur d'exécution local des conteneurs, dans notre example `containerd`.
* `kubectl` est le client Kubernetes, il suffit de l'installer sur la machine qui vous permettra de piloter votre cluster Kubernetes.

Comme précédemment, nous vous recommandons de copier-coller le code ci-dessous dans un script et de l'exécuter sur chacune des machines.

```shell
#!/bin/bash

set -euxo pipefail

sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl
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

Veuillez noter que le script bloque les mises à jour de kubeadm, kubectl, et kubelet afin de prévenir toute mise à jour intempestive de Kubernetes, par exemple suite à des mises à jour de sécurité avec les commandes `apt-get`.

## Créer le cluster Kubernetes

Sur votre noeud maître, lancer la commande suivante:
```shell
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

Voici ce que vous allez voir apparaître sur votre console, dans les dernières lignes de la sortie standard de la commande:
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

**Trois instructions très importantes** sont présentes ici:

- la manière de configurer `kubectl`, le client Kubernetes. Dans notre exemple nous utiliserons comme machine cliente le noeud maître Kubernetes, sur lequel nous lancerons donc les commandes ci-dessous:
```bash
# Ici vous devez être connecté avec votre compte utilisateur et non pas en tant que `root`
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
- l'installation d'un plugin réseau, nous choisirons ici un des plus populaire: `calico`. Il suffit de lancer la commande ci-dessous sur votre client Kubernetes, que nous venons de configurer. A noter que dans notre exemple, le client est également le maître Kubernetes:
```shell
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/custom-resources.yaml -O
kubectl create -f custom-resources.yaml
```
- la commande à exécuter sur tous vos autres noeuds afin qu'ils rejoignent le cluster Kubernetes:
```shell
sudo kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

`<control-plane-host>:<control-plane-port>` contient le nom DNS ou l'IP et le port du maître Kubernetes. `<token>` est le jeton, dont la durée de vie est limitée, qui permet au noeud courant de s'identifier auprès du master. Enfin, `<hash>` permet au noeud courant de s'assurer de l'authenticité du maître.

{{% notice note %}}
Il n'est pas recommandé d'exécuter les containers applicatifs sur les nœuds maîtres Kubernetes pour des raisons de sécurité. C'est pourquoi nous vous recommandons d'utiliser des nœuds maîtres dédiés à l'éxécution des composant système Kubernetes.
{{% /notice %}}

## Vérifier que tout fonctionne

La commande suivante permet de vérifier que votre cluster Kubernetes est opérationnel:

```shell
kubectl cluster-info                                                                                                                                                        ✔  10376  09:19:37
Kubernetes master is running at https://127.0.0.1:32903
KubeDNS is running at https://127.0.0.1:32903/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

La commande ci-dessous permet de lister l'ensemble de vos noeuds:
```shell
kubectl get nodes
```

Finalement, l'installation de Kubernetes avec `kubeadm` est plutôt simple, n'est-ce pas :-).

## Supprimer le cluster

La [documentation officielle](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down) détaille toutes les opérations nécessaires pour supprimer votre cluster.
Si vous avez créé vos machines dans un Cloud, une solution équivalente et beaucoup plus simple est bien entendu de les supprimer, puis des les recréer dans leur état initial.

## Automatiser l'installation

Voici un exemple de script permettant d'automatiser ce processus: https://github.com/k8s-school/k8s-advanced/tree/master/0_kubeadm. Pour en apprendre plus, vous pouvez nous contacter pour participer à une de [nos formations](https://k8s-school.fr/formations-kubernetes).


