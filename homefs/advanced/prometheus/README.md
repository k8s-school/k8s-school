# Pre-requisite 

An up and running k8s cluster

# Install premetheus-operator+kube-prometheus 

## Use helm

Detailed documentation is available here:
https://itnext.io/kubernetes-monitoring-with-prometheus-in-15-minutes-8e54d1de2e13

```shell
helm init

# Hack for running helm on GKE
#
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'   
helm init --service-account tiller --upgrade
#

helm install stable/prometheus-operator --name prometheus-operator --namespace monitoring

# Prometheus access:
kubectl port-forward -n monitoring prometheus-prometheus-operator-prometheus-0 9090 &

# Grafana access:
# login as admin with password prom-operator
kubectl port-forward $(kubectl get  pods --selector=app=grafana -n  monitoring --output=jsonpath="{.items..metadata.name}") -n monitoring  3000 &
```


