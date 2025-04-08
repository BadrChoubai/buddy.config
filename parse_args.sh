#!/bin/env bash

# Default values
DRY_RUN="0"
action="install"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --install) action="install" ;;
        --uninstall) action="uninstall" ;;
        --refresh) action="refresh" ;;
        --dry) DRY_RUN="1" ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
    shift
done

# Export variables so they can be used in setup
export DRY_RUN action
