#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"

dot_apps="$script_dir/.apps"
dot_pkgs="$script_dir/.pkgs"

# ---- Help ----
for arg in "$@"; do
    case "$arg" in
        --help|-h)
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
            ;;
    esac
done

# ---- Confirmation ----
if [[ "${SKIP_PROMPT:-0}" == "0" ]]; then
    echo ""
    log "INFO" "The following will be installed:"
    if [[ -s "$dot_pkgs" ]]; then
        echo "  - Apt Packages from .pkgs"
        [[ "${DRY_RUN}" == "0" ]] && (
            sed '/^\s*$/d; s/^/    - /' "$dot_pkgs"
            echo ""
        )
    fi

    if [[ -s "$dot_apps" ]]; then
        echo "  - Snap Packages from .apps"
        [[ "${DRY_RUN}" == "0" ]] && (
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
    mapfile -t PKGS < <(grep -Ev '^\s*(#|$)' "$dot_pkgs")
    if (( ${#PKGS[@]} > 0 )); then
        log "INFO" "Updating apt package index..."
        [[ "${DRY_RUN:-0}" == "0" ]] && sudo apt update -y
        for pkg in "${PKGS[@]}"; do
            if dpkg -l | grep -qw "$pkg"; then
                log "INFO" "$pkg already installed."
            else
                log "INFO" "Installing $pkg..."
                if [[ "${DRY_RUN:-0}" == "1" ]]; then
                    log "INFO" "[DRY RUN] Would install $pkg via apt"
                else
                    sudo apt install -y "$pkg"
                    # Append app name after successful install
                    if [[ $? -eq 0 ]]; then
                        echo "$pkg" >> .pkgs.installed
                    else
                        log "ERROR" "Failed to install $app"
                    fi
                fi
            fi
        done
    fi
fi

# ---- Install Snap Apps ----
if [[ -f "$dot_apps" ]]; then
    mapfile -t APPS < <(grep -Ev '^\s*(#|$)' "$dot_apps")
    for app in "${APPS[@]}"; do
        if snap list | grep -qw "$app"; then
            log "INFO" "$app already installed (snap)."
        else
            log "INFO" "Installing $app via snap..."
            if [[ "${DRY_RUN:-0}" == "1" ]]; then
                log "INFO" "[DRY RUN] Would install $app via snap"
            else
                sudo snap install "$app" --classic
                # Append app name after successful install
                if [[ $? -eq 0 ]]; then
                    echo "$app" >> .apps.installed
                else
                    log "ERROR" "Failed to install $app"
                fi
            fi
        fi
    done
fi

log "INFO" "Installation complete."

