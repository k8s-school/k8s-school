# Init project

```
. ./env.sh
gcloud auth login
gcloud config set project $PROJECT
```

# Connect to instances

``` shell
gcloud compute ssh student@sch-X
```

# Follow Kubernetes install documentation 

https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

NOTE: Docker package is named 'docker-engine' on Debian
