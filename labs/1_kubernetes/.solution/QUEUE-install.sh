set -e
set -x

kubectl apply -f 12-4-rs-queue.yaml
kubectl apply -f 12-5-service-queue.yaml

kubectl  wait --for=condition=Ready pods -l app=work-queue,component=queue --all

QUEUE_POD=$(kubectl get pods -l app=work-queue,component=queue \
	    -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward $QUEUE_POD 8081:8080 &
sleep 3
