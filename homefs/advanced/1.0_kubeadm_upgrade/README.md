# Pre-requisites

Install kubeadm and dependencies in version 1.13.5

# Generate token file

https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-tls-bootstrapping/#token-authentication-file

```
# Format: token,user,uid,"group1,group2,group3"
# Generate token:
head -c 16 /dev/urandom | od -An -t x | tr -d ' '
cat /etc/kubernetes/auth/tokens.csv
02b50b05283e98dd0fd71db496ef01e8,alice,10001,"system:bootstrappers"
492f5cd80d11c00e91f45a0a5b963bb6,bob,10000,"system:bootstrappers"
sudo chmod 600 /etc/kubernetes/auth/tokens.csv
```

# Initialization

Set up kubernetes version to 1.13.0:
https://kubernetes.io/docs/setup/independent/control-plane-flags/

Enable basic auth:
https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/

# Update kubeconfig

USER=alice
kubectl config set-credentials "$USER" --token=02b50b05283e98dd0fd71db496ef01e8
kubectl config set-context $USER --cluster=kubernetes --user=$USER

# Reset


