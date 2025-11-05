#!/bin/env bash

set -e

declare -A levels=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
logging_level="INFO"

log() {
    local log_priority=$1
    local log_message=$2

    #check if level exists
    [[ ${levels[$log_priority]} ]] || return 1

    #check if level is enough
    (( ${levels[$log_priority]} < ${levels[$logging_level]} )) && return 2

    if [[ ${DRY_RUN:-0} -eq 1 ]]; then
        echo "${log_priority}:DRY_RUN: ${log_message}"
    else
        echo "${log_priority}: ${log_message}"
    fi
}
