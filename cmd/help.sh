#!/usr/bin/env bash
set -euo pipefail

# --- Output help message ---
cat <<EOF

Usage: ./setup.sh <command> [options]

Installs and configures your dev environment.

Available Commands:
  clean             - Uninstall dependencies that were removed from configuration
  install           - Install developer environment
  version           - Print version
  help              - Print this message

Options:
  -h, --help        - Print this message

EOF

