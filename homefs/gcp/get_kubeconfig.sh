#!/bin/sh

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/env.sh"

gcloud container clusters get-credentials "$CLUSTER" --zone $REGION --project "$PROJECT"
