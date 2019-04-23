#!/bin/bash

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

usage() {
    cat << EOD
Usage: $(basename "$0") [options]
Available options:
  -D            Delete instances
  -h            This message

Create GCE instances

EOD
}

OPT="-c"

# Get the options
while getopts hD c ; do
    case $c in
        D) OPT="-d" ;;
        h) usage ; exit 0 ;;
        \?) usage ; exit 2 ;;
    esac
done
shift "$((OPTIND-1))"

if [ $# -ne 0 ] ; then
    usage
    exit 2
fi

ZONE="europe-west1-b"
NODE_FIRST_ID=1
NODE_LAST_ID=4
$DIR/manage-instances.sh $OPT $NODE_FIRST_ID $NODE_LAST_ID $ZONE

#ZONE="europe-north1-a"
#NODE_FIRST_ID=9
#NODE_LAST_ID=16
#$DIR/manage-instances.sh $OPT $NODE_FIRST_ID $NODE_LAST_ID $ZONE

#ZONE="europe-west2-a"
#NODE_FIRST_ID=17
#NODE_LAST_ID=24
#$DIR/manage-instances.sh $OPT $NODE_FIRST_ID $NODE_LAST_ID $ZONE

#ZONE="europe-west3-a"
#NODE_FIRST_ID=25
#NODE_LAST_ID=32
#$DIR/manage-instances.sh $OPT $NODE_FIRST_ID $NODE_LAST_ID $ZONE
