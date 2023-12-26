#!/usr/bin/env bash

set -e 
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"
source ./utils.sh

download_url=$(
    curl -s https://api.github.com/repos/coder/code-server/releases/latest |
    jq -r '.assets[] | select(.name|test("_amd64\\.deb$")) | .browser_download_url'
)
mkdir -p /tmp/code-server
pushd /tmp/code-server
curl -sLo "code-server.deb" "${download_url}"
dpkg -i code-server.deb
popd
rm -rf /tmp/code-server
