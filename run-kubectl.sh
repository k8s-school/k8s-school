#!/bin/sh

# Run docker container containing kubectl tools and scripts

# @author  Fabrice Jammes

set -e
# set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

KUBECONFIG="$DIR"/dot-kube

usage() {
    cat << EOD
Usage: $(basename "$0") [options]
Available options:
  -C            Command to launch inside container
  -h            This message

Run docker container containing k8s management tools (helm,
kubectl, ...) and scripts.

EOD
}

# Get the options
while getopts hC:K: c ; do
    case $c in
        C) CMD="${OPTARG}" ;;
        h) usage ; exit 0 ;;
        \?) usage ; exit 2 ;;
    esac
done
shift "$((OPTIND-1))"

if [ $# -ne 0 ] ; then
    usage
    exit 2
fi

mkdir -p "$KUBECONFIG"
mkdir -p "$DIR/dot-ssh"

if [ ! -r "$KUBECONFIG" ]; then
    echo "ERROR: incorrect KUBECONFIG file: $KUBECONFIG"
    exit 2
fi

if [ -z "${CMD}" ]
then
    CMD="bash"
    BASH_OPTS="-it"
fi

# Launch container
#
# Use host network to easily publish k8s dashboard
IMAGE=k8sschool/kubectl
MOUNTS="--volume "$DIR/dot-ssh":$HOME/.ssh"
MOUNTS="$MOUNTS --volume "$KUBECONFIG":$HOME/.kube"
MOUNTS="$MOUNTS --volume "$DIR"/kubectl:$HOME"
MOUNTS="$MOUNTS --volume /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro"

docker pull "$IMAGE"
echo "oOoOoOoOoOo"
echo "Welcome in kubectl container"
echo "oOoOoOoOoOo"
docker run $BASH_OPTS --net=host \
    $MOUNTS --rm \
    --user=$(id -u):$(id -g $USER) \
    -w $HOME \
    "$IMAGE" $CMD
