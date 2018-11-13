# Fork this repository and clone it

Create a github account to fork this repository, then clone it:
```shell
mkdir -p $HOME/src
cd $HOME/src
git clone https://github.com/<GIT-USER>/k8s-school.git
```

# Download keys

At https://drive.google.com/open?id=18Z6sQCwfe0LAzFtloC1AjhYPmpRgNyHZ 

Then run:

```shell
cd k8s-school
mkdir -p dot-ssh
cd dot-ssh
# Move keys here
cp ~/Downloads/id_rsa_sch* .
chmod 600 id_rsa_sch
cd ..
```

# Setup ssh configuration

```shell
./paas/setup-cfg.sh
```

# Set up kubectl client

Get a bash prompt inside docker image with kubectl client:

```shell
./run-kubectl.sh
```

# Setup k8s cluster

```shell
# WARN WARN -- Inside kubectl docker image -- WARN WARN

# Define k8s-orchestrator
# replace CHANGEME with your k8s master hostname
vi /root/scripts/paas/env.sh 
# Set you orchestrator here
# export ORCHESTRATOR="sch-worker-x"

# Linux only: Grant access to ssh keys
chown -R root:root $HOME/.ssh

# Log in orchestrator
ssh $ORCHESTRATOR

# Create k8s master
# apiserver-cert-extra-sans option is a hack for ssh tunnel
# Official documentation available at:
# https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#instructions
sudo kubeadm init --apiserver-cert-extra-sans=localhost

# WARN WARN -- RECORD JOIN COMMAND -- WARN WARN
# example:
# kubeadm join 192.168.56.249:6443 --token h73o12.7r64fz5k0f92er3j \
#   --discovery-token-ca-cert-hash \
#   sha256:f124761234bae63f4806f602a6e6467a10da3c844ff06a4a1c2a7b6ad62dca9d

# Log out orchestrator
exit

# Copy k8s credential to container
# MacOS only: WARN backup any existing $HOME/.kube/config first!!!
./scripts/paas/export-kubeconfig.sh
# Open ssh tunnel to k8s orchestrator
./scripts/paas/ssh-tunnel.sh

# Copy configuration and install pod network
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# Check master is ready
kubectl get nodes

# Join a node
# replace kube-node-yyy with your k8s node hostname
ssh sch-worker-y
sudo kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>
# Log out node 
exit

# Check cluster status
kubectl get nodes 
# Output:
# NAME            STATUS    ROLES     AGE       VERSION
# sch-worker-19   Ready     master    9m        v1.10.3
# sch-worker-20   Ready     <none>    1m        v1.10.3

kubectl get componentstatuses
# Output:
# NAME                 STATUS    MESSAGE              ERROR
# scheduler            Healthy   ok                   
# controller-manager   Healthy   ok                   
# etcd-0               Healthy   {"health": "true"}
 
```

# Install k8s dashboard

See https://github.com/kubernetes/dashboard/ to install it, and https://github.com/kubernetes/dashboard/wiki/Access-control#admin-privileges to grant access right
