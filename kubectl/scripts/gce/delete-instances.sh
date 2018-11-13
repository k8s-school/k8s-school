#!/bin/bash

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/env.sh"

INSTANCE_PREFIX="sch"

for NODE in $NODES 
do
    gcloud compute instances delete -q --zone $ZONE "$NODE"
done


