sudo kubeadm reset
sudo iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
sudo ipvsadm --reset