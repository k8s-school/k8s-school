#/bin/sh

set -e
set -x

curl -O https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json
cat primer-dataset.json
cat primer-dataset.json | kubectl exec -i mongo-0 -c mongodb -- mongoimport --db test --collection restaurants --drop
kubectl exec -it mongo-0 -- mongo test --eval "db.restaurants.find()"



