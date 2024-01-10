#!/bin/bash

set -e 
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"
source ./utils.sh


micromamba_destination="/usr/local/bin"

curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj -C ${micromamba_destination} --strip-components=1 bin/micromamba
echo "Micromamba executable installed."

export MAMBA_ROOT_PREFIX="/opt/conda"
updaterc 'export MAMBA_ROOT_PREFIX="/opt/conda"'
appendpath "${MAMBA_ROOT_PREFIX}/bin" true
mkdir -p "${MAMBA_ROOT_PREFIX}/conda-meta"
touch "${MAMBA_ROOT_PREFIX}/conda-meta/history"
sharedir "${MAMBA_ROOT_PREFIX}"

run_as_user() {
    local cmd=("$@")
    local quoted="$(printf "'%s' " "${cmd[@]}")"
    su --whitelist-environment=MAMBA_ROOT_PREFIX - "${USERNAME}" -c "${quoted}"
}

echo "Configing channels"
micromamba config append --system channels conda-forge
micromamba config append --system channels bioconda
micromamba config set --system channel_priority strict

echo "Initializing shell"
run_as_user micromamba shell init --shell=bash
run_as_user micromamba shell init --shell=zsh

echo "Micromamba configured."

micromamba clean -yaf
