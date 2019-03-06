#!/bin/sh

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

for instance in controller-0 controller-1 controller-2; do
    gcloud compute scp "$DIR"/etcd_install.sh "${instance}":~/
    gcloud compute ssh "${instance}" --command="~/etcd_install.sh"
done

# Verification
gcloud compute ssh "controller-0" --command="\
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem"