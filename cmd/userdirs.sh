#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"

usage() {
    echo ""
    echo "Usage: ./setup_v2.sh userdirs [OPTIONS]"
    echo ""
    echo "Install xdg user directories: Templates, etc" 
    echo ""
    echo "Options:"
    echo "  -n, --dry-run   Show what would be done without making changes"
    echo "  -h, --help      Show this message"
    echo ""
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        -h|--help) usage ;;
        -n|--dry-run) DRY_RUN=1 ;;
    esac
done

log "WARN" "command not implemented"
