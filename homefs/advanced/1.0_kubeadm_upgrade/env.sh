MASTER="node-1"
NODES="node-2 node-3"

ZONE=europe-west1-b
gcloud config set compute/zone $ZONE

SCP="gcloud compute scp"
SSH="gcloud compute ssh"
