#!/bin/sh

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

SCRIPT="worker_install.sh"

WORKERS="worker-0 worker-1 worker-2"

for instance in $WORKERS; do
    gcloud compute scp "$DIR/$SCRIPT" "${instance}":~/
    gcloud compute ssh "${instance}" --command="~/$SCRIPT"
done

# Verification
gcloud compute ssh controller-0 \
  --command "kubectl get nodes --kubeconfig admin.kubeconfig"
