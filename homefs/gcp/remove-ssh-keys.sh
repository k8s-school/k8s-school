#!/bin/sh

# Remove unused ssh keys
# which may prevent 'gcloud compute ssh' working if too numerous

set -e

gcloud compute os-login ssh-keys list | grep -v FINGERPRINT | xargs -I {} -n 1 gcloud compute os-login ssh-keys remove --key={}
