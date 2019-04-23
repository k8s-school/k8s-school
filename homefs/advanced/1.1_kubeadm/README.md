# Pre-requisites

Install kubeadm and dependencies in version 1.13.5

# Generate token file

https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-tls-bootstrapping/#token-authentication-file

```
cat /etc/kubernetes/auth/tokens.csv
02b50b05283e98dd0fd71db496ef01e8,kubelet-bootstrap,10001,"system:bootstrappers"
sudo chmod 600 /etc/kubernetes/auth/tokens.csv
```

# Initialization

Set up kubernetes version to 1.13.0:
https://kubernetes.io/docs/setup/independent/control-plane-flags/

Enable basic auth:
https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/

# Update kubeconfig

 kubectl config set-credentials kubelet-bootstrap --token=02b50b05283e98dd0fd71db496ef01e8
 kubectl config set-context kubelet-bootstrap --cluster=kubernetes --user=kubelet-bootstrap

# Reset


