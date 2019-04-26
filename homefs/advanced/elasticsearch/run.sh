# See https://github.com/helm/charts/tree/master/stable/elastic-stack
helm install --name elk stable/elastic-stack

# It does not work so investigate why and  solve it
# whatch logs and pvcs

helm delete --purge elk
kubectl delete pvc -l release=elk,component=data

# Define storageclass 'local-storage'
kubectl apply -f manifest/local-storage.yaml
# Define it as default
kubectl patch storageclass local-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Create 6 pvs 
kubectl apply -f manifest/pv.yaml

# Re-install
helm install --name elk stable/elastic-stack

# See https://platform9.com/blog/kubernetes-logging-and-monitoring-the-elasticsearch-fluentd-and-kibana-efk-stack-part-2-elasticsearch-configuration/
# logstash and kibana are broken, enable fluentd, disable logstash and fix es url in values.xml
# fix also fluentd configmap: https://platform9.com/blog/kubernetes-logging-and-monitoring-the-elasticsearch-fluentd-and-kibana-efk-stack-part-1-fluentd-architecture-and-configuration/
curl -O https://raw.githubusercontent.com/helm/charts/master/stable/elastic-stack/values.yaml

# Re-install
helm install -f values.yaml --name elk stable/elastic-stack

export POD_NAME=$(kubectl get pods --namespace default -l "app=kibana,release=elk" -o jsonpath="{.items[0].metadata.name}")
echo "Visit http://127.0.0.1:5601 to use Kibana"
kubectl port-forward --namespace default $POD_NAME 5601:5601
