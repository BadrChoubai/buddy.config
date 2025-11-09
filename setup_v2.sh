#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
cmd_dir="$script_dir/cmd"

. "$script_dir/parse_args.sh" "$@"
. "$script_dir/log.sh"

if [[ -f "$script_dir/.env" ]]; then
    . "$script_dir/.env"
else
    log "WARN" "No .env file found at $script_dir/.env"
fi

# Determine command file
cmd_file="$cmd_dir/${action}.sh"

# Command execution
if [[ ! -f "$cmd_file" ]]; then
    log "ERROR" "Unknown action: $action"
    log "INFO" "Available commands:"
    find "$cmd_dir" -type f -name "*.sh" | sed 's#.*/##; s/\.sh$//' | sort
    exit 1
fi

. "$cmd_file" "${CMD_ARGS[@]}" "${POSITIONAL_ARGS[@]}"
