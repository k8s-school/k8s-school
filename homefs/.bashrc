. /etc/bash_completion

PS1="\u@[kubectl]:\w # "


alias ssh="gcloud compute ssh"
alias kshell='kubectl run -i --rm --tty shell --image=ubuntu --restart=Never -- sh'
alias ll="ls -la"

export PATH=/opt/bin:$GOPATH/bin:$GOROOT/bin:$PATH
source <(helm completion bash)

# k8s cli helpers
. /etc/kubectl.completion
alias k='kubectl'
complete -F __start_kubectl k

# See https://github.com/ahmetb/kubectl-aliases
[ -f /etc/kubectl_aliases ] && source /etc/kubectl_aliases
# function kubectl() { echo "+ kubectl $@"; command kubectl $@; }


