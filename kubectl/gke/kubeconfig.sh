
. ./env.sh

for CLUSTER in $EU_CLUSTERS
do
gcloud container clusters get-credentials "$CLUSTER" --zone $EU_REGION --project "$PROJECT"
done

for CLUSTER in $US_CLUSTERS
do
gcloud container clusters get-credentials "$CLUSTER" --zone $US_REGION --project "$PROJECT"
done
