#/bin/sh

set -e
set -x

cp 14-4-master.conf master.conf
cp 14-5-slave.conf slave.conf
cp 14-6-sentinel.conf sentinel.conf
cp 14-7-init.sh init.sh
cp 14-8-sentinel.sh sentinel.sh

kubectl create configmap \
  --from-file=slave.conf=./slave.conf \
  --from-file=master.conf=./master.conf \
  --from-file=sentinel.conf=./sentinel.conf \
  --from-file=init.sh=./init.sh \
  --from-file=sentinel.sh=./sentinel.sh \
redis-config

kubectl apply -f 17-9-redis-service.yaml
kubectl apply -f 17-10-redis.yaml
