# Google cloud platform

Create a k8s cluster in GKE gui (use k8s version: 1.8.8-gke.0), then authenticate:

```shell
# GCE users
$ gcloud container clusters get-credentials cluster-1 --zone us-central1-a --project MYPROJECT
```

# Install premetheus-operator 

## Using helm

```shell
helm init
# hack for GKE
###
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'   
helm init --service-account tiller --upgrade
###
helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
helm install coreos/prometheus-operator --name prometheus-operator --namespace monitoring
helm install coreos/kube-prometheus --name kube-prometheus --set global.rbacEnable=true --namespace monitoring

# Access via proxy
kubectl port-forward -n monitoring kube-prometheus-grafana-6c9496d766-f86kp 3000
```

Then follow documentation:
https://itnext.io/kubernetes-monitoring-with-prometheus-in-15-minutes-8e54d1de2e13
