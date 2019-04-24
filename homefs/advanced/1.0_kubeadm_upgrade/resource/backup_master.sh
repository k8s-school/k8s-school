#!/bin/sh

# Backup k8s
# see https://elastisys.com/2018/12/10/backup-kubernetes-how-and-why/

set -e

DIR=$(cd "$(dirname "$0")"; pwd -P)

DATE=$(date -u +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/backup-$DATE"
mkdir -p "$BACKUP_DIR"

# Backup certificates
sudo cp -r /etc/kubernetes/pki "$BACKUP_DIR"

# Make etcd snapshot
sudo docker run --rm -v "$BACKUP_DIR":/backup \
    --network host \
    -v /etc/kubernetes/pki/etcd:/etc/kubernetes/pki/etcd \
    --env ETCDCTL_API=3 \
    k8s.gcr.io/etcd-amd64:3.2.18 \
    etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
    --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
    snapshot save "/backup/etcd-snapshot.db"

# Get snapshot status
sudo docker run --rm -v "$BACKUP_DIR":/backup \
    --env ETCDCTL_API=3 \
    k8s.gcr.io/etcd-amd64:3.2.18 \
    etcdctl snapshot status "/backup/etcd-snapshot.db"

# Backup kubeadm-config
sudo cp /etc/kubeadm/kubeadm-config.yaml "$BACKUP_DIR"
