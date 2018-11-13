#!/bin/bash

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/env.sh"

gcloud auth login
gcloud config set project $PROJECT
