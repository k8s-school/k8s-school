KUBEADM_VERSION=

DOCKER_VERSION=18.06.1-0ubuntu1.2~18.04.1

# Get latest kubeadm version
sudo apt-get update -q
LATEST_KUBEADM=$(apt-cache madison kubeadm | head -n 1 | cut -d'|' -f2 | xargs)

LATEST_K8S="v1.14.1"

# Remove debconf messages
export TERM="linux"