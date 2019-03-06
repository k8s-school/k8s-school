#!/bin/sh

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

SCRIPT="kcp_rbac.sh"

instance="controller-0"

gcloud compute scp "$DIR/$SCRIPT" "${instance}":~/
gcloud compute ssh "${instance}" --command="~/$SCRIPT"