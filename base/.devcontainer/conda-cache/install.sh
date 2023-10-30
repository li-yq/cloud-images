#!/bin/sh

MAMBA_ROOT_PREFIX=${MAMBA_ROOT_PREFIX:-"/mamba"}
USERNAME=${USERNAME:-${_REMOTE_USER}}

set -e

create_cache_dir() {
    if [ -d "$1" ]; then
        echo "Cache directory $1 already exists. Skip creation..."
    else
        echo "Create cache directory $1..."
        mkdir -p "$1"
    fi

    if [ -z "$2" ]; then
        echo "No username provided. Skip chown..."
    else
        echo "Change owner of $1 to $2..."
        chown -R "$2:$2" "$1"
    fi
}

create_cache_dir "${MAMBA_ROOT_PREFIX}" "${USERNAME}"

echo "Done!"