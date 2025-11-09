#!/usr/bin/env bash
set -euo pipefail

# Declare an associative array
declare -A cmds_usage=(
    [autocomplete]="Installs Bash autocomplete for setup.sh"
    [clean]="Remove untracked apps and packages"
    [config]="Print command-line configuration values"
    [dotfiles]="create symlinks for user dotfiles"
    [help]="Show help message"
    [templates]="initialize XDG_TEMPLATE_DIR"
    [version]="Show version info"
    [install]="Install configured apps and packages"
)

# --- Output help message ---
usage() {
    echo ""
    echo "Usage: ./setup_v2.sh <COMMAND> [OPTIONS]"
    echo ""
    echo "Provides utility commands for configuring your development environment"
    echo ""
    echo "Available Commands:"

    # Print commands and their descriptions
    for cmd in $(printf "%s\n" "${!cmds_usage[@]}" | sort); do
        printf "  %-15s - %s\n" "$cmd" "${cmds_usage[$cmd]}"
    done

    echo ""
    echo "Options:"
    echo "  -h, --help      - Print this message"
    echo ""
    exit 0
}

usage
