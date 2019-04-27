set -e

# TODO delete nginw with label
kubectl run nginx --generator=run-pod/v1 --image=nginx -n logging

# Wait for logging:nginx to be in running state
while true
do
    sleep 2
    STATUS=$(kubectl get pods -n logging nginx -o jsonpath="{.status.phase}")
    if [ "$STATUS" = "Running" ]; then
        break
    fi
done

kubectl port-forward -n logging nginx 8081:80&
while true; do curl localhost:8081; sleep 2; done
