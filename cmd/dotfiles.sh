#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"

usage() {
    echo ""
    echo "Usage: ./setup_v2.sh dotfiles [OPTIONS]"
    echo ""
    echo "Installs dotfiles using symlinks"
    echo ""
    echo "Options:"
    echo "  -n, --dry-run   Show what would be done without making changes"
    echo "  -h, --help      Show this message"
    echo ""
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        -h|--help) usage ;;
        -n|--dry-run) DRY_RUN=1 ;;
    esac
done

# ---- Locate files for symlink ----

dotfiles="$script_dir/env"
config_dir="$HOME/.config"

log "INFO" "Linking dotfiles from $dotfiles"

# Create ~/.config if missing
mkdir -p "$config_dir"

# List of mappings: source => destination
declare -A links=(
  ["$dotfiles/.config/alacritty"]="$config_dir/alacritty"
  ["$dotfiles/.config/nvim"]="$config_dir/nvim"
  ["$dotfiles/.config/tmux"]="$config_dir/tmux"
  ["$dotfiles/.zshrc"]="$HOME/.zshrc"
  ["$dotfiles/.zsh_profile"]="$HOME/.zsh_profile"
)

# Function to safely create symlink
link_file() {
  local src="$1"
  local dest="$2"

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    log "WARN" "Backing up existing $dest to $dest.bak"
    mv "$dest" "$dest.bak"
  fi

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "INFO" "ln -sfn \"$src\" \"$dest\""
  else
    ln -sfn "$src" "$dest"
    log "INFO" "Linked $dest → $src"
  fi
}

# Iterate over all defined links
for src in "${!links[@]}"; do
  link_file "$src" "${links[$src]}"
done

log "INFO" "Dotfiles linked successfully!"
