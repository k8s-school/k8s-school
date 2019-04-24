. /etc/bash_completion

PS1="\u@[kubectl]:\w # "

# k8s cli helpers
. /opt/bash/kubectl.completion
alias k='kubectl'

alias ssh="gcloud compute ssh"
