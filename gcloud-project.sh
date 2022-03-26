#!/bin/bash

set -euxo pipefail

PROJECT="coastal-sunspot-206412"
ZONE="asia-east1-c"
USER="k8sstudent_gmail_com"

gcloud config configurations create k8s-school
gcloud config configurations activate k8s-school
gcloud config set project coastal-sunspot-206412
gcloud config set compute/zone $ZONE

gcloud config list