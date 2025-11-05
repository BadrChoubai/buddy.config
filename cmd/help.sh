#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
dot_pkgs="$script_dir/.pkgs"
dot_apps="$script_dir/.apps"
. "$script_dir/log.sh"

# --- Prepare package and app lists ---
packages=""
apps=""

if [[ -s "$dot_pkgs" ]]; then
    packages=$(sed '/^\s*$/d; s/^/  - /' "$dot_pkgs")
else
    packages="  (none)"
fi

if [[ -s "$dot_apps" ]]; then
    apps=$(sed '/^\s*$/d; s/^/  - /' "$dot_apps")
else
    apps="  (none)"
fi

# --- Output help message ---
cat <<EOF

Usage: ./setup.sh [ACTION] [OPTIONS]

Installs and configures your dev environment.

Packages:
$packages

Apps:
$apps

Options:
  -n, --dry-run     Show what would be done without making changes
  -y                Skip confirmation prompt
  -h, --help        Show this message

EOF

