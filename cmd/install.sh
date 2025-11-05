#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"

dot_apps="$script_dir/.apps"
dot_pkgs="$script_dir/.pkgs"

# ---- Common Installation Function ----
# Installs packages from a file, checking if already installed
# Args: $1=file_path, $2=package_type (apt|snap), $3=check_command, $4=install_command
install_packages() {
    local file_path="$1"
    local pkg_type="$2"
    local check_cmd="$3"
    local install_cmd="$4"
    
    if [[ ! -f "$file_path" ]]; then
        return 0
    fi
    
    mapfile -t PACKAGES < <(grep -Ev '^\s*(#|$)' "$file_path")
    
    for pkg in "${PACKAGES[@]}"; do
        if eval "$check_cmd" | grep -qw "$pkg"; then
            log "INFO" "$pkg already installed."
        else
            log "INFO" "Installing $pkg..."
            if [[ ${DRY_RUN:-0} -eq 1 ]]; then
                log "INFO" "[DRY RUN] Would install $pkg via $pkg_type"
            else
                eval "$install_cmd \"$pkg\""
            fi
        fi
    done
}

# ---- Help ----
if [[ "${SHOW_HELP:-0}" -eq 1 ]]; then
    echo ""
    log "INFO" "Usage: ./setup.sh install [OPTIONS]"
    echo ""
    echo "Installs all configured development tools and links configuration files."
    echo ""
    echo "Options:"
    echo "  -n, --dry-run   Show what would be done without making changes"
    echo "  -y                 Skip confirmation prompt"
    echo "  -h, --help         Show this message"
    echo ""
    exit 0
fi

# ---- Confirmation ----
if [[ ${SKIP_PROMPT:-0} -eq 0 ]]; then
    echo ""
    log "INFO" "The following will be installed:"
    if [[ -s "$dot_pkgs" ]]; then
        echo "  - Apt Packages from .pkgs"
        [[ ${DRY_RUN:-0} -eq 0 ]] && (
            sed '/^\s*$/d; s/^/    - /' "$dot_pkgs"
            echo ""
        )
    fi

    if [[ -s "$dot_apps" ]]; then
        echo "  - Snap Packages from .apps"
        [[ ${DRY_RUN:-0} -eq 0 ]] && (
            sed '/^\s*$/d; s/^/    - /' "$dot_apps"
            echo ""
        )
    fi

    read -p "Continue? (y/n) " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        log "INFO" "Installation aborted."
        exit 0
    fi
fi

# ---- Install APT Packages ----
if [[ -f "$dot_pkgs" ]]; then
    log "INFO" "Updating apt package index..."
    [[ ${DRY_RUN:-0} -eq 0 ]] && sudo apt update -y
    install_packages "$dot_pkgs" "apt" "dpkg -l" "sudo apt install -y"
fi

# ---- Install Snap Apps ----
install_packages "$dot_apps" "snap" "snap list" "sudo snap install --classic"

log "INFO" "Installation complete."

