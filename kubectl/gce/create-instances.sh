#!/bin/bash

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/env.sh"

for NODE in $NODES 
do
    gcloud beta compute --project="$PROJECT" instances create "${NODE}" \
	    --zone="$ZONE" --machine-type="$MACHINE_TYPE" --subnet=default \
	    --scopes=https://www.googleapis.com/auth/cloud-platform \
	    --image=debian-9-stretch-v20180911 \
	    --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard \
	    --boot-disk-device-name=instance-1
done


