#!/bin/env bash

# Default values
dry_run="0"
action="install"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry)
            dry_run="1"
            ;;
        --uninstall)
            action="uninstall"
            ;;
        --up)
            action="up"
            ;;
        --down)
            action="down"
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
export dry_run action
