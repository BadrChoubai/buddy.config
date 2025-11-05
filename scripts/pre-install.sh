#!/bin/env bash

. "/home/buddy/buddy.config/log.sh"

set -e

log "INFO" "installing pre-requisite packages"
if [[ "$DRY_RUN" == 0 ]]; then 
    sudo apt update
    sudo apt upgrade -y
else
    log "INFO" "apt update, apt upgrade would run"
fi

packages=(git)

for pkg in "${packages[@]}"; do
    if [[ "$DRY_RUN" == 0 ]]; then
        sudo apt install -y "$pkg"
    else 
        log "INFO" "Would install $pkg"
    fi
done


