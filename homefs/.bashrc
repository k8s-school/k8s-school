. /etc/bash_completion

PS1="\u@[kubectl]:\w # "

# k8s cli helpers
. /etc/kubectl.completion
alias k='kubectl'

alias ssh="gcloud compute ssh"

export PATH=/opt/bin:$GOPATH/bin:$GOROOT/bin:$PATH
