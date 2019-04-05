#!/bin/sh

set -e
set -x

gcloud config set compute/region europe-north1
gcloud config set compute/zone europe-north1-a

# Create VPC
gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom

# Provision subnet
gcloud compute networks subnets create kubernetes \
    --network kubernetes-the-hard-way \
    --range 10.240.0.0/24

# Allow internal communication across all protocols
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal \
    --allow tcp,udp,icmp \
    --network kubernetes-the-hard-way \
    --source-ranges 10.240.0.0/24,10.200.0.0/16

# Allow external SSH, ICMP, and HTTPS
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
    --allow tcp:22,tcp:6443,icmp \
    --network kubernetes-the-hard-way \
    --source-ranges 0.0.0.0/0

gcloud compute firewall-rules list --filter="network:kubernetes-the-hard-way"

# Allocate a static IP address that will be attached to the external load balancer fronting the Kubernetes API Servers:
gcloud compute addresses create kubernetes-the-hard-way \
	  --region $(gcloud config get-value compute/region)

gcloud compute addresses list --filter="name=('kubernetes-the-hard-way')"

# Create three compute instances which will host the Kubernetes control plane
for i in 0 1 2; do
    gcloud compute instances create controller-${i} \
        --async \
	--boot-disk-size 200GB \
	--can-ip-forward \
	--image-family ubuntu-1804-lts \
	--image-project ubuntu-os-cloud \
	--machine-type n1-standard-1 \
	--private-network-ip 10.240.0.1${i} \
	--scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
	--subnet kubernetes \
	--tags kubernetes-the-hard-way,controller
done

# Create three compute instances which will host the Kubernetes worker nodes
for i in 0 1 2; do
    gcloud compute instances create worker-${i} \
        --async \
	--boot-disk-size 200GB \
	--can-ip-forward \
	--image-family ubuntu-1804-lts \
	--image-project ubuntu-os-cloud \
	--machine-type n1-standard-1 \
	--metadata pod-cidr=10.200.${i}.0/24 \
	--private-network-ip 10.240.0.2${i} \
	--scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
	--subnet kubernetes \
	--tags kubernetes-the-hard-way,worker
done

gcloud compute instances list

