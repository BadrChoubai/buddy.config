#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"


usage() {
    echo ""
    echo "Usage: ./setup_v2.sh config [OPTIONS] [VALUE]"
    echo ""
    echo "prints configuration values from .env"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this message"
    echo ""
    exit 0
}
#
# ---- Parse options ----
for arg in "$@"; do
    case "$arg" in
        -h|--help) usage ;;
    esac
done

dot_env="$script_dir/.env"

if [[ ! -f "$dot_env" ]]; then
    log "ERROR" ".env file not found at $dot_env"
    exit 1
fi

key="${POSITIONAL_ARGS[0]:-}"

if [[ -z "$key" ]]; then
    echo
    cat $dot_env
    exit 0
fi

dot_env=".env"

if [[ ! -f "$dot_env" ]]; then
    echo "ERROR: .env file not found at $dot_env"
    exit 1
fi

# Look up key in .env
value=$(grep -E "^$key=" "$dot_env" | cut -d= -f2- || true)

if [[ -z "$value" ]]; then
    echo "ERROR: Key '$key' not found in $dot_env"
    exit 1
fi

echo \ "
$value
"
