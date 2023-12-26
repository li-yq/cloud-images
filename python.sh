#!/usr/bin/env bash

set -e 
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"
source ./utils.sh

aptinstall python3 python3-doc python3-pip python3-venv python3-dev python3-tk

# setup venv
python3 -m venv /opt/venv
prependpath /opt/venv/bin true
export PATH


echo 'Installing Pipx'
export PIPX_HOME=/opt/pipx
export PIPX_BIN_DIR="${PIPX_HOME}/bin"
updaterc "export PIPX_HOME=${PIPX_HOME}"
updaterc "export PIPX_BIN_DIR=${PIPX_BIN_DIR}"
prependpath $PIPX_BIN_DIR true
export PATH

export PYTHONUSERBASE=/tmp/pip-tmp
export PIP_CACHE_DIR=/tmp/pip-tmp/cache
/usr/bin/pip install --disable-pip-version-check --user pipx
$PYTHONUSERBASE/bin/pipx install --force pipx
rm -rf $PYTHONUSERBASE

# install jupyter
pipx install jupyter-core
pipx inject jupyter-core --include-apps jupytext jupyterlab
pip install ipykernel
jupyter kernelspec remove -y python3
/opt/venv/bin/ipython kernel install

sharedir "${PIPX_HOME}"
sharedir "/opt/venv"
