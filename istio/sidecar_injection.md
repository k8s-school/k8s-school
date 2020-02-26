# Sidecar injection

## Manual

Inject the sidecar into the deployment using the in-cluster configuration.
```shell
$ ./bin/istioctl kube-inject -f samples/sleep/sleep.yaml | kubectl apply -f -
```
    serviceaccount/sleep created
    service/sleep created
    deployment.extensions/sleep created

Verify that the sidecar has been injected into the sleep pod with 2/2 under the READY column.
```shell
kubectl get pod  -l app=sleep
```
    NAME                     READY   STATUS    RESTARTS   AGE
    sleep-544c6997cd-9tvbp   2/2     Running   0          1m9s

## Automatic

For automatic sidecar injection, Istio relies on Mutating Admission Webhook. Let’s look at the details of the istio-sidecar-injector mutating webhook configuration.
```shell
$ kubectl get mutatingwebhookconfiguration istio-sidecar-injector -o yaml
```
Automatic sidecar injection is enabled by default. It can be disabled by adding below option to _helm install_ command line:

    --set sidecarInjectorWebhook.enabled=false
Create a new namespace called istio and add _istio-injection_ label
```shell
$ kubectl create ns istio
$ kubectl label namespace istio istio-injection=enabled
$ kubectl get ns --show-labels
$ kubectl get namespace -L istio-injection
```
Set _istio_ namespace in the current context:

    kubectl config set-context $(kubectl config current-context) --namespace=istio
 >     istio namespace is set in the current context to avoid adding '-n istio' to each kubectl command
```shell
$ kubectl apply -f samples/sleep/sleep.yaml
```
    serviceaccount/sleep created
    service/sleep created
    deployment.extensions/sleep created
Verify that the sidecar has been injected into the sleep pod with 2/2 under the READY column.
```shell
kubectl get pod -l app=sleep
```
    NAME                     READY   STATUS    RESTARTS   AGE
    sleep-7d457d69b5-rgkct   2/2     Running   0          25s

