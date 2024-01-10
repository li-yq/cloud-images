#!/usr/bin/env bash

set -e 
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"
source ./utils.sh
. /etc/profile.d/rc.sh

pip install numpy scipy matplotlib seaborn

aptinstall r-cran-tidyverse r-cran-broom r-cran-svglite

aptinstall tmux moreutils parallel

pipx install "snakemake==7"
pipx install dvc

micromamba install -n base -y csvtk jq seqkit
