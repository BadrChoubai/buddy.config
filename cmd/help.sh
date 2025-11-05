#!/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"

# --- Determine if a command-specific help is requested ---
if [[ $# -gt 0 ]]; then
    cmd="$1"
    cmd_file="$script_dir/cmd/$cmd.sh"

    if [[ -f "$cmd_file" ]]; then
        bash "$cmd_file" --help
        exit 0
    else
        log "ERROR" "Unknown command: $cmd"
        log "INFO" "Available commands:"
        find "$script_dir/cmd" -type f -name "*.sh" | sed 's#.*/##; s/\.sh$//'
        exit 1
    fi
fi

# --- No command given: show global help ---
echo ""
log "INFO" "Usage: ./setup.sh [COMMAND] [OPTIONS]"
echo ""
echo "Available commands:"
for f in "$script_dir/cmd"/*.sh; do
    cmd_name="$(basename "$f" .sh)"
    # Skip files starting with --
    if [[ "$cmd_name" == --* ]]; then continue; fi
    echo "  $cmd_name"
done
echo ""
echo "Options:"
echo "  --dry, --dry-run   Show what would be done without making changes"
echo "  -y                 Skip confirmation prompt"
echo "  -h, --help         Show this message"
echo ""

