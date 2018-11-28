#/bin/sh

set -e
set -x

# Shell
# kubectl exec redis-2 -it -c redis   -- sh  

kubectl exec redis-2 -c redis   -- redis-cli -p 26379 sentinel get-master-addr-by-name redis
sleep 1
kubectl exec redis-2 -c redis -- redis-cli -p 6379 get foo
sleep 1
kubectl exec redis-2 -c redis -- redis-cli -p 6379 set foo 10
sleep 1
kubectl exec redis-0 -c redis -- redis-cli -p 6379 set foo 10
sleep 1
kubectl exec redis-2 -c redis -- redis-cli -p 6379 get foo
