# ── Directories ────────────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# ── Editor ─────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"

# ── PATH ───────────────────────────────────────────────────────
[[ -d /usr/local/go/bin ]] && export PATH=$PATH:/usr/local/go/bin
(( $+commands[go] )) && export PATH=$PATH:$(go env GOPATH)/bin
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
