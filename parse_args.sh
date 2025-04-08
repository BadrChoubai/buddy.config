#!/bin/env bash

# Default values
DRY_RUN="0"
action="install"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry)
            DRY_RUN="1"
            ;;
        --uninstall)
            action="uninstall"
            ;;
        --refresh)
            action="refresh"
            ;;
        *)
            echo "Unknown argument: $1"
            ;;
    esac
    shift
done

# Export variables so they can be used in setup
export DRY_RUN action
