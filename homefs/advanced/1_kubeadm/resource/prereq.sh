VERSION=1.13.5-00
DOCKER_VERSION=18.06.1-0ubuntu1.2~18.04.1
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet="$VERSION" kubeadm="$VERSION" kubectl="$VERSION"
apt-mark hold kubelet kubeadm kubectl
apt-get install -y docker.io="$VERSION" ipvsadm
apt autoremove
