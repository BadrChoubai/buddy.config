#!/bin/env bash

. "/home/buddy/buddy.config/log.sh"

set -e

log "INFO" "installing pre-requisite packages"

sudo apt update
sudo apt upgrade -y

sudo apt autoremove -y

packages=(git)

for pkg in "${packages[@]}"; do
    sudo apt install -y "$pkg"
done

