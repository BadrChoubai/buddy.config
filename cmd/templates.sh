#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"

usage() {
    echo ""
    echo "Usage: ./setup_v2.sh templates [OPTIONS]"
    echo ""
    echo "git clone TEMPLATES_REPOSITORY into XDG_TEMPLATES_DIR"
    echo ""
    echo "Options:"
    echo "  -n, --dry-run   Show what would be done without making changes"
    echo "  -h, --help      Show this message"
    echo ""
    exit 0
}

# ---- Parse options ----
for arg in "$@"; do
    case "$arg" in
        -h|--help) usage ;;
        -n|--dry-run) DRY_RUN=1 ;;
    esac
done


if [[ -z "${TEMPLATES_REPOSITORY:-}" ]]; then
    log "ERROR" "TEMPLATES_REPOSITORY is unset"
    exit 1
else
    log "INFO" "TEMPLATES_REPOSITORY"
    log "INFO" "$TEMPLATES_REPOSITORY"
fi

TEMPLATES_DESTINATION="${XDG_TEMPLATES_DIR:-$HOME/Templates}"

git_clone() {
    git clone "$1" "$2"
}

install_templates() {
    echo
    log "INFO" "Cloning templates..."
    log "INFO" "From:   $1"
    log "INFO" "To:     $2"
    echo

    git_clone "$1" "$2"

    (
        pushd "$TEMPLATES_DESTINATION"
        rm -rf .git
        popd
    )
    
    log "INFO" "Templates directory set up..."
}

# Skip actual cloning if dry-run mode is enabled
if [[ "$DRY_RUN" != 1 ]]; then
    install_templates "$TEMPLATES_REPOSITORY" "$TEMPLATES_DESTINATION"
else
    log "INFO" "Would run: install_templates"
fi

