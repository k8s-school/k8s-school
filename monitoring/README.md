k8s monitoring
==============

# Prometheus

## Installation procedure

See https://github.com/coreos/prometheus-operator/blob/master/contrib/kube-prometheus/

```
# On workstation
cd <path_to_repos>/k8s-school/kubectl/scripts/
git clone --single-branch --depth=1 -b master https://github.com/coreos/prometheus-operator.git

And then, in kubectl container,  follow quickstart instructions:
https://github.com/coreos/prometheus-operator/tree/master/contrib/kube-prometheus#quickstart
```

## Access Web UI

### Via kubectl proxy


```
kubectl port-forward -n monitoring grafana-5b68464b84-h9wx4 3000:3000
```

Credentials are admin, admin.
