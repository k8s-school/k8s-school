#!/bin/sh

# Pre-requisite: set up k8s cluster and set KUBECONFIG

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

NODE="kind-worker"
DN="kind"
INGRESS_DN="ingress.$DN"

kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-ds.yaml
kubectl --namespace=kube-system get pods
kubectl get services --namespace=kube-system

# Ingress to Traefik web ui
kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/ui.yaml

NODE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-worker)
echo "${NODE_IP} $INGRESS_DN" | sudo tee -a /etc/hosts

# Return 404
curl http://"$INGRESS_DN"

# Add kind support to ingress rule
curl https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/cheese-ingress.yaml | \
    sed "s/.minikube/.$DN/" | \
    kubectl apply -f -

# Ingress ui is available 
curl http://"$INGRESS_DN"

# TLS support
#
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=$INGRESS_DN"
kubectl -n kube-system create secret tls traefik-ui-tls-cert --key=tls.key --cert=tls.crt

# WARN: add fix to official doc file
kubectl apply -f "$DIR/manifest/tls-ingress.yaml"

# Patch https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-rbac.yaml
# add a TLS entrypoint by adding the following args to the container spec:
# --defaultentrypoints=http,https
# --entrypoints=Name:https Address::443 TLS
# --entrypoints=Name:http Address::80
#
# And open hostPort 443
kubectl apply -f "$DIR/manifest/tls-traefik-ds.yaml"

# Password for traefik web ui
#
sudo apt install apache2-utils
htpasswd  -bc ./auth user pass
kubectl create secret generic mysecret --from-file auth --namespace=kube-system
# Patch ingress according to doc: https://docs.traefik.io/user-guide/kubernetes/#creating-the-secret
kubectl apply -f manifest/auth-ingress.yaml

# Name-based routing: https://docs.traefik.io/user-guide/kubernetes/#name-based-routing
#
kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/cheese-deployments.yaml
kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/cheese-services.yaml
kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/cheese-ingress.yaml

# Add kind support to ingress rule
curl https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/cheese-ingress.yaml | \
    sed "s/\.minikube/\.$DN/" | \
    kubectl apply -f -

echo "${NODE_IP} stilton.$DN cheddar.$DN wensleydale.$DN" | sudo tee -a /etc/hosts

# Open in browser
curl http://stilton."$DN"


# Path-based Routing: https://docs.traefik.io/user-guide/kubernetes/#path-based-routing
#
curl https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/cheeses-ingress.yaml | \
    sed "s/\.minikube/\.$DN/" | \
    kubectl apply -f -

echo "${NODE_IP} cheeses.$DN" | sudo tee -a /etc/hosts

# Open in browser
# WARN: do not forget the final slash
http://cheeses.kind/stilton/

