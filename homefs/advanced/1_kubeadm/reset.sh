#!/bin/sh

# Reset a k8s cluster an all nodes

set -e

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/env.sh"

parallel -vvv --tag -- "gcloud compute ssh {} -- sh /tmp/resource/reset.sh" ::: "$MASTER" $NODES