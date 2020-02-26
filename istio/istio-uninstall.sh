#!/bin/bash

# Uninstall Istio
# Check https://istio.io/docs/setup/getting-started/#uninstall

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR"/env.sh

istioctl manifest generate --set profile=demo | kubectl delete -f -
