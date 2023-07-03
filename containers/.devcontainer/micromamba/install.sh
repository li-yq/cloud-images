#!/bin/bash -i

set -e

source ./library_scripts.sh

# nanolayer is a cli utility which keeps container layers as small as possible
# source code: https://github.com/devcontainers-contrib/nanolayer
# `ensure_nanolayer` is a bash function that will find any existing nanolayer installations, 
# and if missing - will download a temporary copy that automatically get deleted at the end 
# of the script
ensure_nanolayer nanolayer_location "v0.4.45"


$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/mamba-org/devcontainer-features/micromamba:1" 
    
detect_user() {
    local user_variable_name=${1:-username}
    local possible_users=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    if [ "${!user_variable_name}" = "auto" ] || [ "${!user_variable_name}" = "automatic" ]; then
        declare -g ${user_variable_name}=""
        for current_user in ${possible_users[@]}; do
            if id -u "${current_user}" > /dev/null 2>&1; then
                declare -g ${user_variable_name}="${current_user}"
                break
            fi
        done
    fi
    if [ "${!user_variable_name}" = "" ] || [ "${!user_variable_name}" = "none" ] || ! id -u "${!user_variable_name}" > /dev/null 2>&1; then
        declare -g ${user_variable_name}=root
    fi
}

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
detect_user USERNAME
echo "Will run as user ${USERNAME}"

echo "Disable auto activate"
su -c "test -f ~/.bashrc && sed --in-place '/^micromamba activate # added by micromamba devcontainer feature$/d' ~/.bashrc" - "${USERNAME}"
su -c "test -f ~/.zshrc && sed --in-place '/^micromamba activate # added by micromamba devcontainer feature$/d' ~/.zshrc" - "${USERNAME}"

echo 'Done!'
