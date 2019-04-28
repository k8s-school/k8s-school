#!/bin/sh

set -e

DIR=$(cd "$(dirname "$0")"; pwd -P)

APP=create-gke-cluster
docker run --rm -v "$PWD":"/usr/src/$APP" -w "/usr/src/$APP" golang:1.12.4 go build -v
cp "$APP" $DIR/../../rootfs/opt/bin
