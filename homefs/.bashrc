. /etc/bash_completion

PS1="\u@[kubectl]:\w # "

# k8s cli helpers
. /etc/kubectl.completion
alias k='kubectl'

alias ssh="gcloud compute ssh"
alias kshell='kubectl run -i --rm --tty shell --image=busybox --restart=Never -- sh'

export PATH=/opt/bin:$GOPATH/bin:$GOROOT/bin:$PATH
