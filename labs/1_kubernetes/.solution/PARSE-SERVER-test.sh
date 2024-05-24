#/bin/sh

set -e
set -x

# From:
# http://docs.parseplatform.org/parse-server/guide/#saving-your-first-object

# Use kubectl get svc parse-server
IP=$(kubectl get svc parse-server -o go-template='{{.spec.clusterIP}}')

# Warn: launch after having  run 'kubectl port-forward ...'
kubectl run -i --rm --tty shell --image=busybox -- \
    curl -X POST \
    -H "X-Parse-Application-Id: my-app-id" \
    -H "Content-Type: application/json" \
    -d '{"score":123,"playerName":"Sean Plott","cheatMode":false}' \
    http://${IP}:1337/parse/classes/GameScore

