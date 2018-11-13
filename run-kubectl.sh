#!/bin/sh

# Run docker container containing kubectl tools and scripts

# @author  Fabrice Jammes

set -e
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

KUBECONFIG="$DIR"/dot-kube

usage() {
    cat << EOD
Usage: $(basename "$0") [options]
Available options:
  -C            Command to launch inside container
  -K            Path to k8s configuration file,
                default to $DIR if readable
  -h            This message

Run docker container containing k8s management tools (helm,
kubectl, ...) and scripts.

EOD
}
set -x

# Get the options
while getopts hC:K: c ; do
    case $c in
        C) CMD="${OPTARG}" ;;
        K) KUBECONFIG="${OPTARG}" ;;
        h) usage ; exit 0 ;;
        \?) usage ; exit 2 ;;
    esac
done
shift "$((OPTIND-1))"

if [ $# -ne 0 ] ; then
    usage
    exit 2
fi


case "$KUBECONFIG" in
    /*) ;;
    *) echo "expect absolute path" ; exit 2 ;;
esac

# strip trailing slash
KUBECONFIG=$(echo $KUBECONFIG | sed 's%\(.*[^/]\)/*%\1%')

if [ ! -r "$KUBECONFIG" ]; then
    echo "ERROR: incorrect KUBECONFIG file: $KUBECONFIG"
    exit 2
fi

if [ -z "${CMD}" ]
then
    BASH_OPTS="-it --volume "$DIR"/kubectl/scripts:/root/scripts"
    CMD="bash"
fi

# Launch container
#
# Use host network to easily publish k8s dashboard
IMAGE=k8sschool/kubectl
docker pull "$IMAGE"
docker run $BASH_OPTS --net=host \
    --rm \
    --volume "$DIR/dot-ssh":/root/.ssh \
    --volume "$KUBECONFIG":/root/.kube \
    "$IMAGE" $CMD
