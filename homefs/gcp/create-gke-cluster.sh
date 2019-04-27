#!/bin/sh

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/env.sh"

CLUSTERS="cluster-1"
REGION="us-central1-a"

for CLUSTER in $CLUSTERS
do
gcloud beta container --project "$PROJECT" clusters create "$CLUSTER" --zone "$REGION" \
--no-enable-basic-auth --cluster-version "1.11.8-gke.6" --machine-type "n1-standard-2" \
--image-type "COS" --disk-type "pd-standard" --disk-size "100" \
--scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
--preemptible --num-nodes "2" --no-enable-cloud-logging --no-enable-cloud-monitoring \
--no-enable-ip-alias --network "projects/coastal-sunspot-206412/global/networks/default" \
--subnetwork "projects/coastal-sunspot-206412/regions/us-central1/subnetworks/default" \
--enable-autoscaling --min-nodes "2" --max-nodes "4" \
--addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair
done
