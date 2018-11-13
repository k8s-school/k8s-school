curl -O https://kubernetes.io/docs/tutorials/stateless-application/guestbook/redis-master-deployment.yaml
curl -O https://kubernetes.io/docs/tutorials/stateless-application/guestbook/redis-master-service.yaml
curl -O https://kubernetes.io/docs/tutorials/stateless-application/guestbook/redis-slave-deployment.yaml
curl -O https://kubernetes.io/docs/tutorials/stateless-application/guestbook/redis-slave-service.yaml
curl -O https://kubernetes.io/docs/tutorials/stateless-application/guestbook/frontend-deployment.yaml
curl -O https://kubernetes.io/docs/tutorials/stateless-application/guestbook/frontend-service.yaml
kubectl apply -f redis-master-deployment.yaml 
kubectl apply -f redis-master-service.yaml
kubectl apply -f redis-slave-deployment.yaml
kubectl apply -f redis-slave-service.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

# Access service at http://$IP:32081/ (where ip is one of dind docker host for # k8s worker)
