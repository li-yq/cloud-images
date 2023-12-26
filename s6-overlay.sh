#!/usr/bin/env bash

set -e 
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"
source ./utils.sh

release=$( curl -s https://api.github.com/repos/just-containers/s6-overlay/releases/latest | jq -r '.tag_name' )

curl -sLo /tmp/s6-overlay-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/${release}/s6-overlay-noarch.tar.xz
tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
curl -sLo /tmp/s6-overlay-x86_64.tar.xz https://github.com/just-containers/s6-overlay/releases/download/${release}/s6-overlay-x86_64.tar.xz
tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

