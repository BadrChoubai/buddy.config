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
    echo "Usage: ./setup_v2.sh install [OPTIONS]"
    echo ""
    echo "Installs all configured apps and packages that are missing from the system."
    echo ""
    echo "Options:"
    echo "  -n, --dry-run   Show what would be done without making changes"
    echo "  -y              Skip confirmation prompt"
    echo "  -h, --help      Show this message"
    echo ""
    exit 0
}

# ---- Parse options ----
for arg in "$@"; do
    case "$arg" in
        -h|--help) usage ;;
        -n|--dry-run) DRY_RUN=1 ;;
        -y) SKIP_PROMPT=1 ;;
    esac
done

# ---- Compute missing items ----
touch "$dot_pkgs" "$dot_apps" "$installed_pkgs" "$installed_apps"

TO_INSTALL_PKGS=$(comm -13 <(sort "$installed_pkgs") <(sort "$dot_pkgs"))
TO_INSTALL_APPS=$(comm -13 <(sort "$installed_apps") <(sort "$dot_apps"))

if [[ -z "$TO_INSTALL_PKGS" && -z "$TO_INSTALL_APPS" ]]; then
    log "INFO" "Everything is already installed. Nothing to do."
    exit 0
fi

log "INFO" "The following will be installed:"
if [[ -n "$TO_INSTALL_PKGS" ]]; then
    echo "  - Apt Packages:"
    echo "$TO_INSTALL_PKGS" | sed 's/^/    - /'
fi
if [[ -n "$TO_INSTALL_APPS" ]]; then
    echo "  - Snap Apps:"
    echo "$TO_INSTALL_APPS" | sed 's/^/    - /'
fi

if [[ "$SKIP_PROMPT" == "0" ]]; then
    read -p "Continue? (y/n) " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        log "INFO" "Installation aborted."
        exit 0
    fi
fi

install_missing() {
    local to_install="$1"
    local install_cmd="$2"
    local item_type="$3"
    local lock_file="$4"

    if [[ -z "$to_install" ]]; then
        log "INFO" "No $item_type to install."
        return
    fi

    echo "$to_install" | while read -r item; do
        [[ -z "$item" ]] && continue
        if [[ "$DRY_RUN" == "1" ]]; then
            log "INFO" "[DRY RUN] Would install $item ($item_type)"
        else
            log "INFO" "Installing $item ($item_type)..."
            if $install_cmd "$item"; then
                echo "$item" >> "$lock_file"
                log "INFO" "Installed $item ($item_type)."
            else
                log "ERROR" "Failed to install $item ($item_type)."
            fi
        fi
    done
}

log "INFO" "Starting installation..."

# ---- Install APT Packages ----
install_missing "$TO_INSTALL_PKGS" "sudo apt-get install -y" "package" "$installed_pkgs"

# ---- Install Snap Apps ----
install_missing "$TO_INSTALL_APPS" "sudo snap install --classic" "app" "$installed_apps"

# ---- Finalize ----
if [[ "$DRY_RUN" != "1" ]]; then
    sort -u -o "$installed_pkgs" "$installed_pkgs"
    sort -u -o "$installed_apps" "$installed_apps"
    log "INFO" "Lock files updated."
else
    log "INFO" "[DRY RUN] Lock files not updated."
fi

log "INFO" "Installation complete."

