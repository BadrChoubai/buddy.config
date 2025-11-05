#!/bin/env bash
set -euo pipefail

# Default values
DRY_RUN=0
SHOW_HELP=0
SKIP_PROMPT=0
ACTION_SET=0
action="install"  # default action
CMD_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            SHOW_HELP=1
            CMD_ARGS+=("$1")
            shift
            ;;
        --dry)
            DRY_RUN=1
            CMD_ARGS+=("$1")
            shift
            ;;
        -y)
            SKIP_PROMPT=1
            CMD_ARGS+=("$1")
            shift
            ;;
        --version)
            action="--version"
            ACTION_SET=1
            shift
            ;;
        -*)
            echo "Unknown flag: $1"
            exit 1
            ;;
        *)
            if [[ $ACTION_SET -eq 0 ]]; then
                action="$1"
                ACTION_SET=1
            else
                CMD_ARGS+=("$1")
            fi
            shift
            ;;
    esac
done

export action DRY_RUN SHOW_HELP SKIP_PROMPT CMD_ARGS

