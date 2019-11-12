FROM debian:stretch
MAINTAINER Fabrice Jammes <fabrice.jammes@in2p3.fr>

# RUN echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list

# Start with this long step not to re-run it on
# each Dockerfile update
RUN apt-get -y update && \
    apt-get -y install apt-utils && \
    apt-get -y upgrade && \
    apt-get -y clean

RUN apt-get -y install curl bash-completion git gnupg jq \
    lsb-release \
    openssh-client parallel \
    unzip vim wget

# Install Google cloud SDK
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    apt-key add - && \
    apt-get -y update && apt-get -y install google-cloud-sdk

# Install helm
ENV HELM_VERSION 2.14.3
RUN wget -O /tmp/helm.tgz \
    https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    cd /tmp && \
    tar zxvf /tmp/helm.tgz && \
    rm /tmp/helm.tgz && \
    chmod +x /tmp/linux-amd64/helm && \
    mv /tmp/linux-amd64/helm /usr/local/bin/helm

# Install kubectl
ENV KUBECTL_VERSION 1.15.3
RUN wget -O /usr/local/bin/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install kustomize
ENV KUSTOMIZE_VERSION v3.3.0
RUN wget -O /tmp/kustomize.tgz \
    https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    tar zxvf /tmp/kustomize.tgz && \
    rm /tmp/kustomize.tgz && \
    chmod +x kustomize && \
    mv kustomize /usr/local/bin/kustomize

# Install kubeval
ENV KUBEVAL_VERSION 0.9.0
RUN wget https://github.com/garethr/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz && \
    tar xf kubeval-linux-amd64.tar.gz && \
    mv kubeval /usr/local/bin && \
    rm kubeval-linux-amd64.tar.gz

RUN wget -q --show-progress --https-only --timestamping \
    https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 \
    https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 && \
    chmod o+x cfssl_linux-amd64 cfssljson_linux-amd64 && \
    mv cfssl_linux-amd64 /usr/local/bin/cfssl && \
    mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

ENV GO_VERSION 1.12.2
ENV GO_PKG go${GO_VERSION}.linux-amd64.tar.gz
RUN wget https://dl.google.com/go/$GO_PKG && \
    tar -xvf $GO_PKG && \
    mv go /usr/local

ENV GOROOT /usr/local/go
ENV GOPATH /go

# Install kubectl completion
# setup autocomplete in bash, bash-completion package should be installed first.
RUN kubectl completion bash > /etc/kubectl.completion

RUN wget -O /etc/kubectl_aliases https://raw.githubusercontent.com/ahmetb/kubectl-alias/master/.kubectl_aliases

COPY rootfs /

# Expose kubernetes dashboard
EXPOSE 8001

ARG FORCE_GO_REBUILD=false
RUN $GOROOT/bin/go get -v github.com/k8s-school/clouder
