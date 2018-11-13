#!/bin/sh

# Create docker image containing kops tools and scripts

# @author  Fabrice Jammes

set -e
#set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

IMAGE="k8sschool/kubectl:latest"

echo $DIR

# CACHE_OPT="--no-cache"

docker build $CACHE_OPT --tag "$IMAGE" "$DIR/kubectl"
docker push "$IMAGE"
