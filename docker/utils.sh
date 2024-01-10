#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive
export PIP_NO_CACHE_DIR=off
export USE_EMOJI=false

UBUNTU_CODENAME=jammy
USERNAME=vscode
GROUP=users
USERID=1000
GROUPID=1000

updaterc() {
    echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
    echo "$1" >> /etc/profile.d/rc.sh
}

prependpath() {
    PATH="$1:${PATH}"
    if [[ "$2" == "true" ]] ; then
        updaterc "if [[ \"\${PATH}\" != *\"${1}\"* ]]; then export PATH=${1}:\${PATH}; fi"
    fi
}
appendpath() {
    PATH="$1:${PATH}"
    if [[ "$2" == "true" ]] ; then
        updaterc "if [[ \"\${PATH}\" != *\"${1}\"* ]]; then export PATH=\${PATH}:${1}; fi"
    fi
}

sharedir() {
    directory="$1"
    mkdir -p "${directory}"
    chown -R "${USERNAME}:${GROUP}" "${directory}"
    chmod -R g+r+w+s "${directory}"
}


aptinstall () {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        needaptclean="true"
        apt-get -y update
        apt-get -y install --no-install-recommends "$@"
    fi
}

finish() {
    if [[ "$needaptclean" == "true" ]] ; then
        apt-get -y clean
        rm -rf /var/lib/apt/lists/*
    fi
}
trap finish EXIT

