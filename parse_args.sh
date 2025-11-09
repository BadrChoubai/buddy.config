#!/usr/bin/env bash
set -euo pipefail

# Default values
action="help"
ACTION_SET=0
CMD_ARGS=()
POSITIONAL_ARGS=()
DRY_RUN=0
SHOW_HELP=0
SKIP_PROMPT=0

while [[ "$#" -gt 0 ]]; do
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
        -y|--skip-prompt)
            SKIP_PROMPT=1
            CMD_ARGS+=("$1")
            shift
            ;;
        --version)
            action="version"
            ACTION_SET=1
            shift
            ;;
        *)
            if [[ $ACTION_SET -eq 0 ]]; then
                action="$1"
                ACTION_SET=1
            else
                POSITIONAL_ARGS+=("$1")
            fi
            shift
            ;;
    esac
done

export action DRY_RUN SHOW_HELP SKIP_PROMPT CMD_ARGS POSITIONAL_ARGS

