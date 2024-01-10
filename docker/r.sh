#!/usr/bin/env bash

set -e 
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"
source ./utils.sh

# repo setup
curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc >/dev/null
echo "deb [arch=amd64] https://cloud.r-project.org/bin/linux/ubuntu ${UBUNTU_CODENAME}-cran40/" >/etc/apt/sources.list.d/cran-ubuntu.list
curl -fsSL https://eddelbuettel.github.io/r2u/assets/dirk_eddelbuettel_key.asc | tee -a /etc/apt/trusted.gpg.d/cranapt_key.asc >/dev/null
echo "deb [arch=amd64] https://r2u.stat.illinois.edu/ubuntu ${UBUNTU_CODENAME} main" >/etc/apt/sources.list.d/cranapt.list
# Pinning
cat <<EOF >"/etc/apt/preferences.d/99cranapt"
Package: *
Pin: release o=CRAN-Apt Project
Pin: release l=CRAN-Apt Packages
Pin-Priority: 700
EOF

aptinstall \
    r-base \
    r-cran-languageserver r-cran-httpgd r-cran-irkernel \
    python3-gi python3-apt \

R -q -e 'install.packages("bspm")'
echo "options(bspm.sudo = TRUE)" >>/etc/R/Rprofile.site
echo "bspm::enable()" >>/etc/R/Rprofile.site

. /etc/profile.d/rc.sh
pipx install radian

# Set up IRkernel
echo "Register IRkernel..."
R -q -e "IRkernel::installspec(user = FALSE)"

# install quarto
mkdir -p /tmp/quarto
pushd /tmp/quarto
download_url=$(curl -sL https://quarto.org/docs/download/_download.json | grep -oP "(?<=\"download_url\":\s\")https.*amd64\.deb")
curl -sLo "quarto-cli.deb" "${download_url}"
dpkg -i quarto-cli.deb
popd
rm -rf /tmp/quarto

# Clean up
rm -rf /tmp/Rtmp*
