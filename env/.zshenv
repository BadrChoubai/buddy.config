# ── Directories ────────────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# ── Editor ─────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"

# ── PATH ───────────────────────────────────────────────────────
typeset -U path  # drop duplicate entries
[[ -d /usr/local/go/bin ]] && path+=/usr/local/go/bin
[[ -d "$HOME/go/bin" ]] && path+="$HOME/go/bin"
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
