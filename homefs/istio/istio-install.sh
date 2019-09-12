#!/bin/bash

set -e
set -x

ISTIO_VERSION="1.2.5"
NS="istio-system"

DIR=$(cd "$(dirname "$0")"; pwd -P)

# Helm auto completion:
source <(helm completion bash)
# echo 'source <(helm completion bash)' >> ~/.bashrc

ISTIO_DIR="$DIR/istio-${ISTIO_VERSION}"

echo "Download istio (version $ISTIO_VERSION)"
if [ ! -d "$ISTIO_DIR" ]; then
    curl -L https://git.io/getLatestIstio | ISTIO_VERSION="$ISTIO_VERSION" sh -
fi
cd "$ISTIO_DIR"

echo "Init helm"
kubectl apply -f install/kubernetes/helm/helm-service-account.yaml
helm init --service-account=tiller

echo "Wait until Tiller pod is Ready"
kubectl -n kube-system wait --timeout=300s --for=condition=Ready $(kubectl -n kube-system get pods -l app=helm -o=name)

echo "Install the Istio initializer (istio-init) chart to bootstrap all the Istio’s CRDs"

helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system

echo "Wait until all pods status are **Completed**"
kubectl -n istio-system wait --timeout=300s --for=condition=complete job --all

echo "Verify that all 23 Istio CRDs were committed to the Kubernetes api-server"
kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l
# NAME                      READY   STATUS      RESTARTS   AGE
# istio-init-crd-10-nbksb   0/1     Completed   0          45s
# istio-init-crd-11-6gtct   0/1     Completed   0          45s
# istio-init-crd-12-qdpb5   0/1     Completed   0          45s

echo "Install the istio chart with a custom profile"
helm install install/kubernetes/helm/istio --name istio --namespace istio-system \
--set gateways.istio-ingressgateway.type=NodePort \
--set grafana.enabled=true \
--set tracing.enabled=true \
--set kiali.enabled=true \
--set prometheus.enabled=true \
--set prometheus.service.nodePort.enabled=true

echo "Wait until all pods' status are **Completed** or **Running** or **Succeeded**. This step takes a longer time then previous ones."
kubectl -n istio-system wait --timeout=300s --for=condition=available deploy --all


echo "Ensure all Helm charts (istio-init and istio) are correctly deployed to kubernetes cluster"
helm ls
#    NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
#    istio           1               Sun Aug 18 16:15:45 2019        DEPLOYED        istio-1.2.4             1.2.4           istio-system
#    istio-init      1               Sun Aug 18 16:13:49 2019        DEPLOYED        istio-init-1.2.4        1.2.4           istio-system
