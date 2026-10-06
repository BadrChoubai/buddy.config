#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"

dot_pkgs="$script_dir/.pkgs"

# Default package manager if not set in .env
: "${PACKAGE_MANAGER:=dnf}"
PM="$PACKAGE_MANAGER"

usage() {
    cat <<EOF

Usage: ./provision.sh install [OPTIONS]

Installs all configured packages that are missing from the system.

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
        -y|--skip-prompt) SKIP_PROMPT=1 ;;
    esac
done

log "INFO" "Using package manager: $PM"

# ---- Define package manager commands ----
case "$PM" in
    apt)
        is_installed() { dpkg -s "$1" &> /dev/null; }
        install_pkgs() { sudo apt install -y "$@"; }
        ;;
    dnf)
        is_installed() { rpm -q "$1" &> /dev/null; }
        install_pkgs() { sudo dnf install -y "$@"; }
        ;;
    brew)
        is_installed() { brew list "$1" &> /dev/null; }
        install_pkgs() { brew install "$@"; }
        ;;
    *)
        log "ERROR" "Unsupported PACKAGE_MANAGER: $PM"
        exit 1
        ;;
esac

if [[ ! -f "$dot_pkgs" ]]; then
    log "ERROR" "Package list not found at $dot_pkgs"
    exit 1
fi

# ---- Find missing packages ----
to_install=()
while IFS= read -r pkg; do
    is_installed "$pkg" || to_install+=("$pkg")
done < <(grep -Ev '^\s*($|#)' "$dot_pkgs")

if [[ ${#to_install[@]} -eq 0 ]]; then
    log "INFO" "Everything is already installed. Nothing to do."
    exit 0
fi

log "INFO" "The following will be installed:"
printf "  - %s\n" "${to_install[@]}"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "INFO" "[DRY RUN] Nothing installed."
    exit 0
fi

# ---- Prompt for confirmation ----
if [[ "${SKIP_PROMPT:-0}" == "0" ]]; then
    read -rp "Continue? (y/n) " CONFIRM
    [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { log "INFO" "Installation aborted."; exit 0; }
fi

# ---- Install in a single transaction ----
install_pkgs "${to_install[@]}"

log "INFO" "Installation complete."
