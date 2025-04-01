#!/bin/env bash

log() {
    if [[ "$dry_run" == "1" ]]; then
        printf "[DRY_RUN]: $1\n"
    else
        printf "$1\n"
    fi
}

