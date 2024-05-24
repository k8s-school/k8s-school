#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

cp $DIR/../*.yaml $DIR

echo "Installing queue server"
$DIR/QUEUE-install.sh
$DIR/QUEUE-test.sh

echo "Installing MongoDB"
$DIR/MONGODB-install.sh
$DIR/MONGODB-test.sh


