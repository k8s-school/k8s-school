kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-deployment.yaml
kubectl --namespace=kube-system get pods
kubectl get services --namespace=kube-system

# Ingress to Traefik web ui
kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/ui.yaml

NODE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kube-node-1)
echo "${NODE_IP} traefik-ui.minikube" | sudo tee -a /etc/hosts

