
. ./env.sh

for CLUSTER in $CLUSTERS
do
gcloud beta container --project "$PROJECT" clusters create "$CLUSTER" --zone "$REGION" --username "admin" --cluster-version "1.9.7-gke.6" --machine-type "custom-1-2048" --image-type "COS" --disk-type "pd-standard" --disk-size "100" --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --preemptible --num-nodes "2" --enable-cloud-logging --enable-cloud-monitoring --network "projects/coastal-sunspot-206412/global/networks/default" --subnetwork "projects/coastal-sunspot-206412/regions/europe-north1/subnetworks/default" --addons HorizontalPodAutoscaling,HttpLoadBalancing,KubernetesDashboard --no-enable-autoupgrade --enable-autorepair
done
