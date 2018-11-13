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
ENV HELM_VERSION 2.7.0
RUN wget -O /tmp/helm.tgz \
    https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    cd tmp && \
    tar zxvf /tmp/helm.tgz && \
    chmod +x /tmp/linux-amd64/helm && \
    mv /tmp/linux-amd64/helm /usr/local/bin/helm-${HELM_VERSION} && \
    ln -s /usr/local/bin/helm-${HELM_VERSION} /usr/local/bin/helm

# Install kubectl
ENV KUBECTL_VERSION 1.9.3
RUN wget -O /usr/local/bin/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install kubeval
ENV KUBEVAL_VERSION 0.7.1
RUN wget https://github.com/garethr/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz && \
    tar xf kubeval-linux-amd64.tar.gz && \
    mv kubeval /usr/local/bin && \
    rm kubeval-linux-amd64.tar.gz

WORKDIR /root

# Install kubectl completion
# setup autocomplete in bash, bash-completion package should be installed first.
RUN mkdir ~/.bash && kubectl completion bash > ~/.bash/kubectl.completion

COPY dot-bashrc .bashrc

# Expose kubernetes dashboard
EXPOSE 8001
