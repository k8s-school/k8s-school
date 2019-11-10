#!/bin/sh

# Run docker container containing kubectl tools and scripts

# @author  Fabrice Jammes

set -e
# set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

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
while getopts hC:d c ; do
    case $c in
        C) CMD="${OPTARG}" ;;
        d) DEV=true ;;
        h) usage ; exit 0 ;;
        \?) usage ; exit 2 ;;
    esac
done
shift "$((OPTIND-1))"

if [ $# -ne 0 ] ; then
    usage
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
IMAGE=k8sschool/k8s-toolbox
if [ "$DEV" = true ]; then
    echo "Running in development mode"
    MOUNTS="$MOUNTS -v $DIR/rootfs/opt:/opt"
fi
MOUNTS="$MOUNTS --volume "$DIR"/homefs:$HOME"
MOUNTS="$MOUNTS --volume /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro"
MOUNTS="$MOUNTS --volume /usr/local/share/ca-certificates:/usr/local/share/ca-certificates"

docker pull "$IMAGE"
echo "oOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoO"
echo "   Welcome in k8s toolbox container"
echo "oOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoO"
docker run $BASH_OPTS --net=host \
    $MOUNTS --rm \
    --user=$(id -u):$(id -g $USER) \
    -w $HOME \
    "$IMAGE" $CMD
