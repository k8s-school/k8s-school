#!/bin/sh

# Create docker image containing kops tools and scripts

# @author  Fabrice Jammes

set -e
#set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

IMAGE="k8sschool/kubectl:latest"

echo $DIR

# CACHE_OPT="--no-cache"

docker build --build-arg FORCE_GO_REBUILD="$(date)" --tag "$IMAGE" "$DIR"
docker push "$IMAGE"
