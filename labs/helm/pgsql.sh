#!/bin/bash

# See https://itnext.io/benchmark-results-of-kubernetes-network-plugins-cni-over-10gbit-s-network-36475925a560

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)


ID=0
NS="helm-$ID"

NODE1_IP=$(kubectl get nodes --selector="! node-role.kubernetes.io/master" \
    -o=jsonpath='{.items[0].status.addresses[0].address}')

# Run on kubeadm cluster
# see "kubernetes in action" p391
kubectl delete ns -l "helm=$NS"
kubectl create namespace "$NS"
kubectl label ns "$NS" "helm=$NS"

# Exercice: Install one postgresql pod with helm and add label "tier:database" to master pod
# Disable data persistence
helm delete pgsql --namespace "$NS" || echo "WARN pgsql release not found"

helm repo add bitnami https://charts.bitnami.com/bitnami || echo "Failed to add bitnami repo"
helm repo update

helm install --version 11.9.1 --namespace "$NS" pgsql bitnami/postgresql --set primary.podLabels.tier="database",persistence.enabled="false"

kubectl run -n "$NS" nginx --image=nginx -l "tier=webserver"
kubectl wait --timeout=60s -n "$NS" --for=condition=Ready pods nginx
kubectl exec -n "$NS" -it nginx -- \
    sh -c "apt-get update && apt-get install -y dnsutils inetutils-ping netcat net-tools procps tcpdump"

kubectl wait --timeout=120s -n "$NS" --for=condition=Ready pods -l app.kubernetes.io/instance=pgsql,tier=database

kubectl exec -n "$NS" nginx -- netcat -q 2 -zv pgsql-postgresql 5432

# Interactive mode
export POSTGRES_PASSWORD=$(kubectl get secret --namespace helm-0 pgsql-postgresql -o jsonpath="{.data.postgres-password}" | \
    base64 -d)
kubectl run pgsql-postgresql-client --rm --tty -i --restart='Never' --namespace helm-0 \
    --image docker.io/bitnami/postgresql:14.5.0-debian-11-r14 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
    --command -- psql --host pgsql-postgresql -U postgres -d postgres -p 5432 -c '\copyright'
