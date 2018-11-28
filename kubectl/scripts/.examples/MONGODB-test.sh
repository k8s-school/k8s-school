#/bin/sh

set -e
set -x

curl -O https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json
cat primer-dataset.json | kubectl exec -it mongo-0 -- mongoimport --db test --collection restaurants --drop
kubectl exec -it mongo-0 -- mongo test --eval "db.restaurants.find()"



