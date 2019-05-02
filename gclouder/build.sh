#!/bin/sh

set -e

DIR=$(cd "$(dirname "$0")"; pwd -P)

APP=gclouder
go build -v
mkdir -p $HOME/src/k8s-school/rootfs/opt/bin
mv "$APP" $HOME/src/k8s-school/rootfs/opt/bin
