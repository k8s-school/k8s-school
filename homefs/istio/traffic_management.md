# Traffic management

## Task 1: Route the traffic to one version only

Redirect all the traffic to reviews v1
```
kubectl apply -f samples/bookinfo/networking/destination-rule-reviews.yaml
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
```

## Task 2: Traffic Shifting

Transfer 50% of the traffic from reviews:v1 to reviews:v3 with the following 
```
kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml
```

## Task 3: Remove routing rules (reset)
```
kubectl delete -f samples/bookinfo/networking/virtual-service-all-v1.yaml
```
## Unistall bookinfo application

Delete the routing rules and terminate the application pods
```
. istio-1.2.4/samples/bookinfo/platform/kube/cleanup.sh
```
Confirm shutdown. There should be no virtualservices (vs)   or destinationrules (dr) or gateway (gw) or pods (po).
```
# kubectl get vs,dr,gw,po
No resources found.
```
