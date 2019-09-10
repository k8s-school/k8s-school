# Deploy the bookinfo sample application

Create a new namespace called _bookinfo_ and add _istio-injection_ label
 
    $ kubectl create ns bookinfo
    $ kubectl label namespace bookinfo istio-injection=enabled
    $ kubectl get ns --show-labels
    $ kubectl get namespace -L istio-injection
Set _bookinfo_ namespace in the current context:

    $ kubectl config set-context $(kubectl config current-context) --namespace=bookinfo

Deploy the bookinfo application:

    $ kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
    service/details created
	serviceaccount/bookinfo-details created
	deployment.apps/details-v1 created
	service/ratings created
	serviceaccount/bookinfo-ratings created
	deployment.apps/ratings-v1 created
	service/reviews created
	serviceaccount/bookinfo-reviews created
	deployment.apps/reviews-v1 created
	deployment.apps/reviews-v2 created
	deployment.apps/reviews-v3 created
	service/productpage created
	serviceaccount/bookinfo-productpage created
	deployment.apps/productpage-v1 created
In order to be able to reach the service from outside we need to create a gateway and a virtual service connected
to it:

    $ kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
    gateway.networking.istio.io/bookinfo-gateway created
    virtualservice.networking.istio.io/bookinfo created

Find out the nodeport on which the istio-ingressgateway is listening and try to reach the bookinfo productpage.

    kubectl get svc -n istio-system istio-ingressgateway

    $ export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
    $ export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
    $ export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
    $ echo $GATEWAY_URL
    172.17.0.2:31380
    $ curl -s http://${GATEWAY_URL}/productpage | grep -o "<title>.*</title>"
    $ curl 172.17.0.3:31380/productpage -I

    while :; do echo ====================================
    sleep 1
    curl -s 172.17.0.3:31380/productpage | grep 'font color' | uniq
    done

