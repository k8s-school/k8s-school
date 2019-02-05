#!/bin/bash

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

OPT="-c"
OPT="-d"

ZONE="europe-west1-b"
NODE_FIRST_ID=1
NODE_LAST_ID=8
$DIR/manage-instances.sh $OPT $NODE_FIRST_ID $NODE_LAST_ID $ZONE

ZONE="europe-north1-a"
NODE_FIRST_ID=9
NODE_LAST_ID=16
$DIR/manage-instances.sh $OPT $NODE_FIRST_ID $NODE_LAST_ID $ZONE

ZONE="europe-west2-a"
NODE_FIRST_ID=17
NODE_LAST_ID=24
$DIR/manage-instances.sh $OPT $NODE_FIRST_ID $NODE_LAST_ID $ZONE

ZONE="europe-west3-a"
NODE_FIRST_ID=25
NODE_LAST_ID=32
$DIR/manage-instances.sh $OPT $NODE_FIRST_ID $NODE_LAST_ID $ZONE
