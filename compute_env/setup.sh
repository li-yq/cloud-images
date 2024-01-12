#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive
export PIP_NO_CACHE_DIR=off
export USE_EMOJI=false

apt-get -y update
apt-get -y upgrade
apt-get -y install --no-install-recommends build-essential

########## micromamba ##########
# install executable
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj -C /usr/local/bin --strip-components=1 bin/micromamba

# setup root prefix
export MAMBA_ROOT_PREFIX="/opt/conda"
export PATH=/opt/conda/bin:${PATH}
mkdir -p "${MAMBA_ROOT_PREFIX}/conda-meta"
touch "${MAMBA_ROOT_PREFIX}/conda-meta/history"

# configuration
micromamba config append --system channels conda-forge
micromamba config append --system channels bioconda
micromamba config set --system channel_priority strict

cat >/etc/profile.d/mamba.sh <<-EOF
	export MAMBA_EXE='/usr/local/bin/micromamba';
	export MAMBA_ROOT_PREFIX='${MAMBA_ROOT_PREFIX}';
	__mamba_setup="\$("\$MAMBA_EXE" shell hook --shell bash --root-prefix "\$MAMBA_ROOT_PREFIX" 2> /dev/null)"
	if [ \$? -eq 0 ]; then
		eval "\$__mamba_setup"
	else
		alias micromamba="\$MAMBA_EXE"  # Fallback on help from mamba activate
	fi
	unset __mamba_setup
	if [[ ":\$PATH:" != *":\${MAMBA_ROOT_PREFIX}/bin:"* ]]; then export PATH=\${MAMBA_ROOT_PREFIX}/bin:\${PATH}; fi
EOF

# fix permission
chown -R 1000:users /opt/conda

########## python ##########
# system-wide python
apt-get -y install --no-install-recommends python3 python3-doc python3-pip python3-venv python3-dev python3-tk

# create venv
VENV_PREFIX=/opt/venv
python3 -m venv ${VENV_PREFIX}

# install pipx in pipx
export PIPX_HOME=/opt/pipx
export PIPX_BIN_DIR="${PIPX_HOME}/bin"
export PIPX_MAN_DIR="${PIPX_HOME}/share/man"
export PATH=$PIPX_BIN_DIR:${VENV_PREFIX}/bin:${PATH}

export PYTHONUSERBASE=/tmp/pip-tmp
export PIP_CACHE_DIR=/tmp/pip-tmp/cache
/usr/bin/pip install --disable-pip-version-check --no-warn-script-location --user pipx
$PYTHONUSERBASE/bin/pipx install --force pipx
rm -rf $PYTHONUSERBASE

# install jupyter
pipx install jupyter-core
pipx inject jupyter-core --include-apps jupytext jupyterlab
pip install ipykernel
jupyter kernelspec remove -y python3
${VENV_PREFIX}/bin/ipython kernel install

# fix permission
chown -R 1000:users ${VENV_PREFIX} /opt/pipx

cat >/etc/profile.d/python.sh <<-EOF
	export PIPX_HOME=${PIPX_HOME}
	export PIPX_BIN_DIR=${PIPX_BIN_DIR}
	export PIPX_MAN_DIR=${PIPX_MAN_DIR}
	if [[ ":\$PATH:" != *":${VENV_PREFIX}/bin:"* ]]; then export PATH=${VENV_PREFIX}/bin:\${PATH}; fi
	if [[ ":\$PATH:" != *":$PIPX_BIN_DIR:"* ]]; then export PATH=$PIPX_BIN_DIR:\${PATH}; fi
EOF

########## R ##########
# setup apt repository
. /etc/os-release
curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc >/dev/null
echo "deb [arch=amd64] https://cloud.r-project.org/bin/linux/ubuntu ${UBUNTU_CODENAME}-cran40/" >/etc/apt/sources.list.d/cran-ubuntu.list
curl -fsSL https://eddelbuettel.github.io/r2u/assets/dirk_eddelbuettel_key.asc | tee -a /etc/apt/trusted.gpg.d/cranapt_key.asc >/dev/null
echo "deb [arch=amd64] https://r2u.stat.illinois.edu/ubuntu ${UBUNTU_CODENAME} main" >/etc/apt/sources.list.d/cranapt.list
cat <<EOF >"/etc/apt/preferences.d/99cranapt"
Package: *
Pin: release o=CRAN-Apt Project
Pin: release l=CRAN-Apt Packages
Pin-Priority: 700
EOF

# install R & R package
apt-get -y update
apt-get -y install --no-install-recommends r-base r-cran-languageserver r-cran-httpgd r-cran-irkernel r-cran-bspm python3-gi python3-apt
echo "options(bspm.sudo = TRUE)" >>/etc/R/Rprofile.site
echo "suppressMessages(bspm::enable())" >>/etc/R/Rprofile.site

# radian
pipx install radian
# jupyter
R -q -e "IRkernel::installspec(user = FALSE)"
# quarto
mkdir -p /tmp/quarto
pushd /tmp/quarto
download_url=$(curl -sL https://quarto.org/docs/download/_download.json | grep -oP "(?<=\"download_url\":\s\")https.*amd64\.deb")
curl -sLo "quarto.deb" "${download_url}"
dpkg -i quarto.deb
popd
rm -rf /tmp/quarto

########## GPU-drivers ##########

mkdir -p /tmp/nvidia
pushd /tmp/nvidia
# curl -fSsl -O https://us.download.nvidia.com/tesla/525.125.06/NVIDIA-Linux-x86_64-525.125.06.run
# sh NVIDIA-Linux-x86_64-525.125.06.run -q --dkms --no-cc-version-check

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
apt-get -y update
# apt-get -y install cuda-toolkit
apt-get -y install cuda-drivers

popd
rm -rf /tmp/nvidia


# clean up
apt-get -y clean
