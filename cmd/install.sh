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

usage() {
    cat <<EOF

Usage: ./setup_v2.sh install [OPTIONS]

Installs all configured apps and packages that are missing from the system.

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
        -y) SKIP_PROMPT=1 ;;
    esac
done

# ---- Prepare lockfiles and package/app lists ----
touch "$dot_pkgs" "$dot_apps" "$installed_pkgs" "$installed_apps"

TO_INSTALL_PKGS=$(comm -13 <(sort "$installed_pkgs") <(grep -Ev '^\s*($|#)' "$dot_pkgs" | sort))
TO_INSTALL_APPS=$(comm -13 <(sort "$installed_apps") <(grep -Ev '^\s*($|#)' "$dot_apps" | sort))

if [[ -z "$TO_INSTALL_PKGS" && -z "$TO_INSTALL_APPS" ]]; then
    log "INFO" "Everything is already installed. Nothing to do."
    exit 0
fi

log "INFO" "The following will be installed:"
[[ -n "$TO_INSTALL_PKGS" ]] && echo "$TO_INSTALL_PKGS" | sed 's/^/  - Package: /'
[[ -n "$TO_INSTALL_APPS" ]] && echo "$TO_INSTALL_APPS" | sed 's/^/  - App: /'

# ---- Prompt for confirmation ----
if [[ "${SKIP_PROMPT:-0}" == "0" ]]; then
    read -p "Continue? (y/n) " CONFIRM
    [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { log "INFO" "Installation aborted."; exit 0; }
fi

# ---- Define package manager commands ----
case "$PM" in
    apt)
        install_pkg_cmd() { sudo apt install -y "$1"; }
        install_app_cmd() { sudo snap install --classic "$1"; }
        ;;
    brew)
        install_pkg_cmd() { brew install "$1"; }
        install_app_cmd() { brew install --cask "$1"; }
        ;;
    *)
        log "ERROR" "Unsupported PACKAGE_MANAGER: $PM"
        exit 1
        ;;
esac

# ---- Install function ----
install_missing() {
    local to_install="$1"
    local install_cmd="$2"
    local item_type="$3"
    local lock_file="$4"

    [[ -z "$to_install" ]] && { log "INFO" "No $item_type to install."; return; }

    local installed_items=()

    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        if [[ "${DRY_RUN:-0}" == "1" ]]; then
            log "INFO" "[DRY RUN] Would install $item ($item_type)"
        else
            log "INFO" "Installing $item ($item_type)..."
            if $install_cmd "$item"; then
                installed_items+=("$item")
                log "INFO" "Installed $item ($item_type)."
            else
                log "ERROR" "Failed to install $item ($item_type)."
            fi
        fi
    done <<< "$to_install"

    # Update lockfile once
    if [[ "${DRY_RUN:-0}" != "1" && ${#installed_items[@]} -gt 0 ]]; then
        printf "%s\n" "${installed_items[@]}" >> "$lock_file"
    fi
}

log "INFO" "Starting installation..."

# ---- Install packages and apps ----
install_missing "$TO_INSTALL_PKGS" install_pkg_cmd "package" "$installed_pkgs"
install_missing "$TO_INSTALL_APPS" install_app_cmd "app" "$installed_apps"

# ---- Finalize ----
if [[ "${DRY_RUN:-0}" != "1" ]]; then
    sort -u -o "$installed_pkgs" "$installed_pkgs"
    sort -u -o "$installed_apps" "$installed_apps"
    log "INFO" "Lock files updated."
else
    log "INFO" "[DRY RUN] Lock files not updated."
fi

log "INFO" "Installation complete."

