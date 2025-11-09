#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"

dot_apps="$script_dir/.apps"
dot_pkgs="$script_dir/.pkgs"
installed_apps="$script_dir/.apps.lock"
installed_pkgs="$script_dir/.pkgs.lock"

# Default package manager if not set in .env
: "${PACKAGE_MANAGER:=apt}"
PM="$PACKAGE_MANAGER"
log "INFO" "Using package manager: $PM"

DRY_RUN=${DRY_RUN:-0}
SKIP_PROMPT=${SKIP_PROMPT:-0}

usage() {
    cat <<EOF

Usage: ./setup_v2.sh clean [OPTIONS]

Removes apps and packages that are installed but no longer in configuration.

Options:
  -n, --dry-run   Show what would be done without making changes
  -y              Skip confirmation prompt
  -h, --help      Show this message

EOF
    exit 0
}

# ---- Parse options ----
for arg in "$@"; do
    case "$arg" in
        -h|--help) usage ;;
        -n|--dry-run) DRY_RUN=1 ;;
    esac
done

# ---- Prepare lockfiles ----
touch "$dot_pkgs" "$dot_apps" "$installed_pkgs" "$installed_apps"

# ---- Compute items to remove ----
TO_REMOVE_PKGS=$(comm -23 <(sort "$installed_pkgs") <(sort "$dot_pkgs"))
TO_REMOVE_APPS=$(comm -23 <(sort "$installed_apps") <(sort "$dot_apps"))

if [[ -z "$TO_REMOVE_PKGS" && -z "$TO_REMOVE_APPS" ]]; then
    log "INFO" "Nothing to remove — system is clean."
    exit 0
fi

log "INFO" "The following will be removed:"
[[ -n "$TO_REMOVE_PKGS" ]] && echo "$TO_REMOVE_PKGS" | sed 's/^/  - Package: /'
[[ -n "$TO_REMOVE_APPS" ]] && echo "$TO_REMOVE_APPS" | sed 's/^/  - App: /'

# ---- Prompt for confirmation ----
if [[ "${SKIP_PROMPT}" == "0" ]]; then
    read -p "Continue? (y/n) " CONFIRM
    [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { log "INFO" "Clean aborted."; exit 0; }
fi

# ---- Define removal commands ----
case "$PM" in
    apt)
        remove_pkg_cmd() { sudo apt-get remove --purge -y "$1"; }
        remove_app_cmd() { sudo snap remove "$1"; }
        ;;
    brew)
        remove_pkg_cmd() { brew uninstall "$1"; }
        remove_app_cmd() { brew uninstall --cask "$1"; }
        ;;
    *)
        log "ERROR" "Unsupported PACKAGE_MANAGER: $PM"
        exit 1
        ;;
esac

# ---- Remove function ----
remove_unconfigured() {
    local to_remove="$1"
    local remove_cmd="$2"
    local item_type="$3"
    local lock_file="$4"

    [[ -z "$to_remove" ]] && { log "INFO" "No $item_type to remove."; return; }

    local removed_items=()

    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        if [[ "$DRY_RUN" == "1" ]]; then
            log "INFO" "[DRY RUN] Would uninstall $item ($item_type)"
        else
            log "INFO" "Uninstalling $item ($item_type)..."
            if $remove_cmd "$item"; then
                removed_items+=("$item")
                log "INFO" "Removed $item ($item_type)."
            else
                log "ERROR" "Failed to remove $item ($item_type)."
            fi
        fi
    done <<< "$to_remove"

    # Update lock file
    if [[ "$DRY_RUN" != "1" && ${#removed_items[@]} -gt 0 ]]; then
        grep -vxFf <(printf "%s\n" "${removed_items[@]}") "$lock_file" > "$lock_file.tmp"
        mv "$lock_file.tmp" "$lock_file"
    fi
}

log "INFO" "Starting clean (removal) operation..."

# ---- Remove packages and apps ----
remove_unconfigured "$TO_REMOVE_PKGS" remove_pkg_cmd "package" "$installed_pkgs"
remove_unconfigured "$TO_REMOVE_APPS" remove_app_cmd "app" "$installed_apps"

# ---- Finalize ----
if [[ "$DRY_RUN" != "1" ]]; then
    sort -u -o "$installed_pkgs" "$installed_pkgs"
    sort -u -o "$installed_apps" "$installed_apps"
    log "INFO" "Lock files updated."
else
    log "INFO" "[DRY RUN] Lock files not updated."
fi

log "INFO" "Clean complete."

