#!/bin/bash

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/env.sh"

usage() {
    cat << EOD
Usage: $(basename "$0") [options] id_first id_last zone 
Available options:
  -c            Create instances
  -d            Destroy instances 
  -h            This message

Manage GCE instances

EOD
}

# Get the options
while getopts cdh i ; do
    case $i in
        c) CREATE=true ;;
        d) CREATE=false ;;
        h) usage ; exit 0 ;;
        \?) usage ; exit 2 ;;
    esac
done
shift "$((OPTIND-1))"

if [ $# -ne 3 ] ; then
    usage
    exit 2
fi

NODE_FIRST_ID=$1
NODE_LAST_ID=$2
ZONE=$3

NODES=$(seq --format "${INSTANCE_PREFIX}%g" \
        --separator=" " "$NODE_FIRST_ID" "$NODE_LAST_ID")

if [ "$CREATE" = true ]; then
    gcloud beta compute --project="$PROJECT" instances create $NODES \
        --zone="$ZONE" --machine-type="$MACHINE_TYPE" --subnet=default \
        --scopes=https://www.googleapis.com/auth/cloud-platform \
        --image=${IMAGE} \
        --image-project=debian-cloud --boot-disk-size=10GB \
        --boot-disk-type=pd-standard \
        --boot-disk-device-name=instance-1
elif [ "$CREATE" = false ]; then
    gcloud compute instances delete -q --zone $ZONE $NODES
else
    >&2 echo "ERROR: missing option"
    usage
fi


