# Istio installation

Helm, the kubernetes package manager, is a prerequisite for Istio installation

## Helm install and setup

Download and install Helm client & server binaries:
```shell
$ curl -O https://get.helm.sh/helm-v2.14.3-linux-amd64.tar.gz
$ tar -vxf helm-v2.14.3-linux-amd64.tar.gz
$ sudo mv linux-amd64/helm linux-amd64/tiller /usr/local/bin/
$ rm -rf linux-amd64 helm-v2.14.3-linux-amd64.tar.gz
```
Helm auto completion:
```shell
$ source <(helm completion bash)
$ echo 'source <(helm completion bash)' >>~/.bashrc
```
Install Tiller (the Helm server-side component) into your Kubernetes Cluster.
```shell
$ kubectl -n kube-system create serviceaccount tiller
serviceaccount/tiller created
$ kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
clusterrolebinding.rbac.authorization.k8s.io/tiller created
$ helm init --service-account tiller
```
Check Tiller status
```
$ kubectl -n kube-system get po | grep tiller

tiller-deploy-8557598fbc-6d2hl 1/1 Running 0 96s
```
## Istio custom install

Download istio (version 1.2.4)
```shell
$ curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.4 sh -
$ cd istio-1.2.4
```
Install the istio-init chart to bootstrap all the Istio’s CRDs:
```shell
$ helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
```
Wait until all pods' status are **Completed**
```shell
$ kubectl -n istio-system get po
```
    NAME                      READY   STATUS      RESTARTS   AGE
    istio-init-crd-10-h8ph6   0/1     Completed   0          2m5s
    istio-init-crd-11-qzh2w   0/1     Completed   0          2m5s
    istio-init-crd-12-jxwb9   0/1     Completed   0          2m5s

Verify that all 23 Istio CRDs were committed to the Kubernetes api-server using the following command:
```shell
$ kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l
23
```
Install the istio chart corresponding to the custom profile defined with 
```shell
$ helm install install/kubernetes/helm/istio --name istio --namespace istio-system \
--set gateways.istio-ingressgateway.type=NodePort \
--set grafana.enabled=true \
--set tracing.enabled=true \
--set kiali.enabled=true \
--set prometheus.enabled=true \
--set prometheus.service.nodePort.enabled=true
```
Wait until all pods' status are **Completed** or **Running**. This step takes a longer time then previous ones.
```shell
$ kubectl -n istio-system get po
```
    NAME                                      READY   STATUS      RESTARTS   AGE
    grafana-6575997f54-xhlwz                  1/1     Running     0          11m
    istio-citadel-7fff5797f-wwmvj             1/1     Running     0          11m
    istio-galley-74d4d7b4db-cpvrt             1/1     Running     0          11m
    istio-ingressgateway-686854b899-9gbr8     1/1     Running     0          11m
    istio-init-crd-10-h8ph6                   0/1     Completed   0          22m
    istio-init-crd-11-qzh2w                   0/1     Completed   0          22m
    istio-init-crd-12-jxwb9                   0/1     Completed   0          22m
    istio-pilot-7fdcbd6f55-hqflf              2/2     Running     0          11m
    istio-policy-79f647bb6-cc4vd              2/2     Running     5          11m
    istio-sidecar-injector-578bfd76d7-pkvmk   1/1     Running     0          11m
    istio-telemetry-cb4486d94-kkvlc           2/2     Running     1          11m
    istio-tracing-555cf644d-kplbg             1/1     Running     0          11m
    kiali-6cd6f9dfb5-hbw54                    1/1     Running     0          11m
    prometheus-7d7b9f7844-rcb8b               1/1     Running     0          11m

Ensure all Helm charts (istio-init and istio) are correctly deployed to kubernetes cluster:
```shell
$ helm ls
```
    NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
    istio           1               Sun Aug 18 16:15:45 2019        DEPLOYED        istio-1.2.4             1.2.4           istio-system
    istio-init      1               Sun Aug 18 16:13:49 2019        DEPLOYED        istio-init-1.2.4        1.2.4           istio-system

# Istio Demos
- [Sidecar injection](https://gitlab.com/fjammes/k8s-school/blob/master/homefs/istio/sidecar_injection.md)
    - Manual
    - Automatic
- [Traffic management](https://gitlab.com/fjammes/k8s-school/blob/master/homefs/istio/traffic_management.md)
    - Deploy the bookinfo sample application


