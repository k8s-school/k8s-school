set -e
set -x

PORT=8081

# Create a work queue called 'keygen'
curl -X PUT localhost:$PORT/memq/server/queues/keygen

# Create 100 work items and load up the queue.
for i in work-item-{0..99}; do
    curl -X POST localhost:$PORT/memq/server/queues/keygen/enqueue \
        -d "$i"
done

curl localhost:$PORT/memq/server/stats

kubectl apply -f 12-7-job-consumers.yaml
