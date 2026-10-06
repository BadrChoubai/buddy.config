#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
. "$script_dir/log.sh"

: "${PACKAGE_MANAGER:=dnf}"

usage() {
    echo ""
    echo "Usage: ./provision.sh dotfiles [OPTIONS]"
    echo ""
    echo "Installs dotfiles by symlinking env/ into \$HOME with GNU Stow"
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

dotfiles="$script_dir/env"

# ---- Ensure stow is available ----
if ! command -v stow &> /dev/null; then
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        log "ERROR" "stow is not installed; install it before a dry run"
        exit 1
    fi
    log "INFO" "stow not found, installing with $PACKAGE_MANAGER"
    case "$PACKAGE_MANAGER" in
        apt)  sudo apt install -y stow ;;
        dnf)  sudo dnf install -y stow ;;
        brew) brew install stow ;;
        *)
            log "ERROR" "Unsupported PACKAGE_MANAGER: $PACKAGE_MANAGER"
            exit 1
            ;;
    esac
fi

# ---- Remove absolute symlinks into env/ ----
# Earlier versions of this script linked with absolute paths, which stow
# does not consider its own and would report as conflicts.
unlink_legacy() {
    local dest="$1"
    [[ -L "$dest" ]] || return 0

    local target
    target="$(readlink "$dest")"
    [[ "$target" == "$dotfiles"/* ]] || return 0

    legacy_found=1
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        log "INFO" "Would remove legacy link $dest → $target"
    else
        rm "$dest"
        log "INFO" "Removed legacy link $dest → $target"
    fi
}

legacy_found=0
shopt -s dotglob nullglob
for src in "$dotfiles"/* "$dotfiles"/.config/*; do
    unlink_legacy "$HOME/${src#"$dotfiles"/}"
done
shopt -u dotglob nullglob

# ---- Link with stow ----
stow_args=(--dir "$script_dir" --target "$HOME" --restow)

if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    # The simulation can't see the legacy links removed, so it would
    # report each of them as a conflict
    if [[ "$legacy_found" -eq 1 ]]; then
        log "INFO" "Would link env/ with stow once legacy links are removed"
        exit 0
    fi
    stow_args+=(--simulate --verbose=1)
else
    # Without a real ~/.config, stow would link the whole directory into the
    # repo and every application would write its config into env/
    mkdir -p "$HOME/.config"
fi

log "INFO" "Linking dotfiles from $dotfiles"

if ! stow "${stow_args[@]}" env; then
    log "ERROR" "stow failed; move or remove the conflicting files above and retry"
    exit 1
fi

log "INFO" "Dotfiles linked successfully!"
