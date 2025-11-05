#!/usr/bin/env bash
set -euo pipefail

# --- Output help message ---
cat <<EOF

Usage: ./setup.sh <command> [options]

Installs and configures your dev environment.

Available Commands:
  install           - Install developer environment

Options:
  -n, --dry-run     - Show what would be done without making changes
  -y                - Skip confirmation prompt
  -h, --help        - Show this message

EOF

