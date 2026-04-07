export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git asdf)

source $ZSH/oh-my-zsh.sh

# ── Aliases ────────────────────────────────────────────────────
alias vim="nvim"
alias k="kubectl"
alias k8s="microk8s"
alias lt="_lt"

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

_lt() {
    local treeignore=""
    if [ -f .gitignore ]; then
        local gitignore_pattern
        gitignore_pattern=$(grep -v '^\s*$\|^\s*#' .gitignore | tr '\n' '|' | sed 's/|$//')
        if [ -n "$gitignore_pattern" ]; then
            treeignore="$treeignore|$gitignore_pattern"
        fi
    fi
    treeignore="${treeignore#|}"
    tree -L 1 -I "$treeignore" "$@"
}

appendPath() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$PATH:$1
    fi
}

prependPath() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$1:$PATH
    fi
}

