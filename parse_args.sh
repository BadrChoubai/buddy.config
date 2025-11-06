#!/bin/env bash
set -euo pipefail

# Default values
action="help"  # default action
ACTION_SET=0
CMD_ARGS=()
DRY_RUN=0
SHOW_HELP=0
SKIP_PROMPT=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            SHOW_HELP=1
            CMD_ARGS+=("$1")
            shift
            ;;
        -n|--dry-run)
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
            action="version"
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
                # Any positional argument after action is invalid
                echo "ERROR: Unknown argument after action '$action': $1"
                exit 1
            fi
            shift
            ;;
    esac
done

export action DRY_RUN FORCE SHOW_HELP SKIP_PROMPT CMD_ARGS

