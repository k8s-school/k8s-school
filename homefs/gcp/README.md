# Pre-requisite

user gmail account must have roles below:
```
Compute OS Admin Login
Compute OS Login
Kubernetes Engine Developer
Service Account User
```
See https://cloud.google.com/compute/docs/instances/managing-instance-access#configure_users for additional informations.

# Init project

```
. ./env.sh
gcloud auth login
gcloud config set project $PROJECT
```

# Connect to instances

``` shell
gcloud compute ssh student@node-X
```

# Follow Kubernetes install documentation 

https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
