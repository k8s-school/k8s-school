set -e
sudo -- kubeadm reset -f
sudo -- sh -c "iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X"
sudo -- ipvsadm --clear
echo "Reset succeed"
echo "-------------"
