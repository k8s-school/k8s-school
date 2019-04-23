#!/bin/bash

set -e

MASTER="node-1"
NODES="node-2 node-3 node-4"

ZONE=europe-west1-b
gcloud config set compute/zone $ZONE

DIR=$(cd "$(dirname "$0")"; pwd -P)

echo "Copy scripts to all nodes"
echo "-------------------------"
parallel --tag -- gcloud compute scp --recurse "$DIR/resource" {}:/tmp ::: "$MASTER" $NODES

echo "Install prerequisites"
echo "---------------------"
parallel -vvv --tag -- "gcloud compute ssh {} -- sudo 'sh /tmp/resource/prereq.sh'" ::: "$MASTER" $NODES

echo "Initialize master"
echo "-----------------"
gcloud compute ssh "$MASTER" -- sh /tmp/resource/init.sh


echo "Join nodes"
echo "----------"
JOIN_CMD=$(gcloud compute ssh "$MASTER" -- 'sudo kubeadm token create --print-join-command')
parallel -vvv --tag -- "gcloud compute ssh {} -- sudo '$JOIN_CMD'" ::: $NODES