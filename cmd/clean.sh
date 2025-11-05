#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"

dot_apps="$script_dir/.apps"
dot_pkgs="$script_dir/.pkgs"
installed_apps="$script_dir/.apps.installed"
installed_pkgs="$script_dir/.pkgs.installed"

DRY_RUN=0

# ---- Parse options ----
for arg in "$@"; do
    case "$arg" in
        --help|-h)
            echo ""
            log "INFO" "Usage: ./cmd/clean.sh [OPTIONS]"
            echo ""
            echo "Removes installed apps and packages that have been removed from configuration."
            echo ""
            echo "Options:"
            echo "  -n, --dry-run   Show what would be done without making changes"
            echo "  -h, --help      Show this message"
            echo ""
            exit 0
            ;;
        --dry-run|-n)
            DRY_RUN=1
            ;;
    esac
done

# ---- Compute what will be removed ----
TO_REMOVE_PKGS=$(comm -23 <(sort "$installed_pkgs") <(sort "$dot_pkgs"))
TO_REMOVE_APPS=$(comm -23 <(sort "$installed_apps") <(sort "$dot_apps"))

log "INFO" "The following will be removed:"
if [[ -n "$TO_REMOVE_PKGS" ]]; then
    echo "  - Apt Packages:"
    echo "$TO_REMOVE_PKGS" | sed 's/^/    - /'
fi
if [[ -n "$TO_REMOVE_APPS" ]]; then
    echo "  - Snap Apps:"
    echo "$TO_REMOVE_APPS" | sed 's/^/    - /'
fi

read -p "Continue? (y/n) " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    log "INFO" "Clean aborted."
    exit 0
fi

remove_unconfigured() {
    local to_remove="$1"
    local uninstall_cmd="$2"
    local item_type="$3"

    if [[ -z "$to_remove" ]]; then
        log "INFO" "No $item_type to remove."
        return
    fi

    echo "$to_remove" | while read -r item; do
        [[ -z "$item" ]] && continue
        log "INFO" "Will uninstall $item ($item_type)"
        if [[ "$DRY_RUN" == "1" ]]; then
            log "INFO" "[DRY RUN] Would uninstall $item ($item_type)"
        else
            $uninstall_cmd "$item"
        fi
    done
}

log "INFO" "Starting clean (removal) operation..."

remove_unconfigured "$TO_REMOVE_PKGS" "sudo apt-get remove --purge -y" "package"
remove_unconfigured "$TO_REMOVE_APPS" "sudo snap remove" "app"

log "INFO" "Clean complete."
