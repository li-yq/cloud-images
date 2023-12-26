#!/bin/bash

set -e 
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"
source ./utils.sh

aptinstall \
        apt-transport-https \
        apt-utils \
        build-essential \
        bzip2 \
        ca-certificates \
        curl \
        git \
        htop \
        iproute2 \
        jq \
        less \
        lsb-release \
        lsof \
        nano \
        ncdu \
        net-tools \
        openssh-client \
        procps \
        psmisc \
        rsync \
        sudo \
        tree \
        unzip \
        wget \
        zip \

groupadd --gid $GROUPID $USERNAME
useradd -s /bin/bash --uid $USERID --gid $USERNAME -G $GROUP -m $USERNAME
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME
