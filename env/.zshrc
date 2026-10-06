export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git kubectl tmux)

[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# ── Aliases ────────────────────────────────────────────────────
alias vim="nvim"
alias k="kubectl"
alias k8s="microk8s"

# ── Functions ──────────────────────────────────────────────────
dotenv() {
    local file_name="${1:-.env}"
    if [[ -f "$file_name" ]]; then
        set -o allexport
        source "$file_name"
        set +o allexport
    else
        echo "dotenv: file '$file_name' not found." >&2
        return 1
    fi
}

lt() {
    tree -L 1 --gitignore "$@"
}


export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
