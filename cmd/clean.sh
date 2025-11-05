#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"

dot_apps="$script_dir/.apps"
dot_pkgs="$script_dir/.pkgs"
installed_apps="$script_dir/.apps.lock"
installed_pkgs="$script_dir/.pkgs.lock"

usage() {
    echo ""
    echo "Usage: ./setup_v2 clean [OPTIONS]"
    echo ""
    echo "Removes installed apps and packages that have been removed from configuration."
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
        -h|-help) usage ;;
        -n|--dry-run) DRY_RUN=1 ;;
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
if [[ -z "$TO_REMOVE_PKGS" && -z "$TO_REMOVE_APPS" ]]; then
    log "INFO" "Nothing to remove — system is clean."
    exit 0
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
        if [[ "$DRY_RUN" == "1" ]]; then
            log "INFO" "[DRY RUN] Would uninstall $item ($item_type)"
        else
            log "INFO" "Uninstalling $item ($item_type)"
            $uninstall_cmd "$item"
        fi
    done
}

log "INFO" "Starting clean (removal) operation..."

remove_unconfigured "$TO_REMOVE_PKGS" "sudo apt-get remove --purge -y" "package"
remove_unconfigured "$TO_REMOVE_APPS" "sudo snap remove" "app"

# ---- Update lock files ----
if [[ "$DRY_RUN" != "1" ]]; then
    log "INFO" "Updating lock files..."
    # Remove uninstalled items from lock files only
    sort "$installed_pkgs" | grep -vxFf <(echo "$TO_REMOVE_PKGS") > "$installed_pkgs.tmp" && mv "$installed_pkgs.tmp" "$installed_pkgs"
    sort "$installed_apps" | grep -vxFf <(echo "$TO_REMOVE_APPS") > "$installed_apps.tmp" && mv "$installed_apps.tmp" "$installed_apps"
    log "INFO" "Lock files updated."
else
    log "INFO" "[DRY RUN] Lock files not updated."
fi

log "INFO" "Clean complete."
