# Kiali

```
kubectl -n istio-system get svc kiali
```
    NAME    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
    kiali   ClusterIP   10.107.105.114   <none>        20001/TCP   99m

By default, Kiali is exposed with a service type ClusterIP. Thus, it is not reachable from ouside Kubernetes cluster.
We have two options to make it reachable externally.

**Option 1: Using kubectl port forwarding**
```
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
```
Then visit http://localhost:20001/kiali/console in your web browser.

**Option 2: Expose Kiali with a service type NodePort**
```
kubectl expose service kiali --type=NodePort --name=kiali-svc --namespace istio-system
```
```
kubectl get svc kiali-svc -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}'
```
Kiali users need to be identified using a username and password to login into Kiali. Create a secret for Kiali whose username is "admin" and passphrase is "admin"
```
kubectl create secret generic kiali -n istio-system --from-literal "username=admin" --from-literal "passphrase=admin"
```
Edit Kiali ConfigMap and set Grafana URL **url: http://grafana:3000**
```
kubectl -n istio-system edit cm kiali
```
# Grafana dashboards

Check grafana service type
```
kubectl -n istio-system get svc grafana
NAME      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
grafana   ClusterIP   10.111.245.166   <none>        3000/TCP   3h26m
```

**Option 1: Using kubectl port forwarding**
```
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000
```
Then visit http://localhost:3000/dashboard/db/istio-mesh-dashboard in your web browser.

**Option 2: Expose Grafana with a service type NodePort**
```
kubectl expose service grafana --type=NodePort --name=grafana-svc --namespace istio-system
```
Retrieve grafana URL:
```
export NODE_IP=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')

export NODE_PORT=$(kubectl get svc grafana-svc -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')

echo http://$NODE_IP:$NODE_PORT/dashboard/db/istio-mesh-dashboard
```
# Tracing with Jaeger

**Option 1: Using kubectl port forwarding**
```
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 15032:16686
```
Open your browser to http://localhost:15032.

**Option 2: Expose Jaeger with a service type NodePort**
```
kubectl expose service jaeger-query --type=NodePort --name=tracing-svc -n istio-system
```
Retrieve Jaeger URL:
```
export NODE_IP=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')

export NODE_PORT=$(kubectl get svc tracing-svc -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')

echo http://$NODE_IP:$NODE_PORT/jaeger/search
```

Install Bookinfo application: https://istio.io/docs/examples/bookinfo/

Generate traces using the Bookinfo sample
```
for i in `seq 1 100`; do curl -s -o /dev/null http://$GATEWAY_URL/productpage; done
```
# Metrics with Prometheus
Retrieve Prometheus URL:
```
export NODE_IP=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')

export NODE_PORT=$(kubectl get svc prometheus-nodeport -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')

echo http://$NODE_IP:$NODE_PORT/graph
```


