#!/bin/bash

set -e

MASTER="node-1"
NODES="node-2 node-3 node-4"

parallel -vvv --tag -- "gcloud compute ssh {} -- sh /tmp/resource/reset.sh" ::: "$MASTER" $NODES