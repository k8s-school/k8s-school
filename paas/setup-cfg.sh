set -e

CLOUD=petasky

DIR=$(cd "$(dirname "$0")"; pwd -P)

# Create configuration
SSH_CFG="$DIR/../dot-ssh"
KUBE_CFG="$DIR/../dot-kube"
mkdir -p "$SSH_CFG" "$KUBE_CFG"
cp "$DIR/config.$CLOUD"/ssh_config "$SSH_CFG/config"
