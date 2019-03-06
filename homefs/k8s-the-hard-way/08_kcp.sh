#!/bin/sh

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

SCRIPT="kcp_install.sh"

for instance in controller-0 controller-1 controller-2; do
    gcloud compute scp "$DIR/$SCRIPT" "${instance}":~/
    gcloud compute ssh "${instance}" --command="~/$SCRIPT"
done

# Verification
for instance in controller-0 controller-1 controller-2; do
    gcloud compute ssh "${instance}" --command='\
        kubectl get componentstatuses --kubeconfig admin.kubeconfig && \
        curl -H "Host: kubernetes.default.svc.cluster.local" -i http://127.0.0.1/healthz'
done
