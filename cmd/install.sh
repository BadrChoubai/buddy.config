#!/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"

# ---- Command-specific help ----
for arg in "$@"; do
    case "$arg" in
        --help|-h)
            echo ""
            log "INFO" "Usage: ./setup.sh install [OPTIONS]"
            echo ""
            echo "Installs all configured development tools and links configuration files."
            echo ""
            echo "Options:"
            echo "  --dry, --dry-run   Show what would be done without making changes"
            echo "  -y                 Skip confirmation prompt"
            echo "  -h, --help         Show this message"
            echo ""
            exit 0
            ;;
    esac
done

# ---- List of installers to skip ----
not=("")  
not_pattern="$(IFS='|'; echo "${not[*]}")"

# ---- Find all install scripts ----
installs=$(find "$script_dir/installs" -mindepth 1 -maxdepth 1 -executable \
    | sort | grep -Ev "/($not_pattern)$")

# ---- Optional user confirmation ----
if [[ "${SKIP_PROMPT:-0}" == "0" ]]; then
    echo ""
    log "INFO" "You are about to install the following:"
    for s in $installs; do
        echo "  - $(basename "$s")"
    done
    echo ""
    read -p "Continue? (y/n) " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        log "INFO" "Installation aborted."
        exit 0
    fi
fi

# ---- Execute installers ----
for s in $installs; do
    log "INFO" "Running: $(basename "$s")"
    if [[ "$DRY_RUN" == "1" ]]; then
        log "INFO" "[DRY RUN] Would execute: $s"
    else
        "$s"
    fi
done

log "INFO" "Installation complete."

