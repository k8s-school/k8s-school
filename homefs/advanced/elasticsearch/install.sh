set -x
set -e

# WARN does not work in dind
# see https://platform9.com/blog/kubernetes-logging-and-monitoring-the-elasticsearch-fluentd-and-kibana-efk-stack-part-2-elasticsearch-configuration/

kubectl create namespace logging

helm install stable/elasticsearch --namespace logging --name elasticsearch --set data.terminationGracePeriodSeconds=0 --set master.persistence.enabled=false     --set data.persistence.enabled=false
helm repo add kiwigrid https://kiwigrid.github.io
helm install --name fluentd --namespace logging kiwigrid/fluentd-elasticsearch --set elasticsearch.host=elasticsearch-client.logging.svc.cluster.local,elasticsearch.port=9200
helm install --name kibana --namespace logging stable/kibana --set env.ELASTICSEARCH_URL=http://elasticsearch-client.logging.svc.cluster.local:9200
generate-log.sh &

export POD_NAME=$(kubectl get pods --namespace logging -l "app=kibana,release=kibana" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward -n logging "$POD_NAME" 5601&
