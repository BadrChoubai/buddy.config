#!/usr/bin/env bash
set -euo pipefail

bash_completion_dir="${BASH_COMPLETION_USER_DIR:-$HOME/.bash_completion.d}"
mkdir -p "$bash_completion_dir"
completion_file="$bash_completion_dir/setup.sh"

cmds=$(find "$(dirname "${BASH_SOURCE[0]}")" -type f -path "*.sh" \
        -exec basename {} .sh \; | sort)

usage() {
    cat <<EOF

Usage: ./setup.sh autocomplete [OPTIONS]

Installs Bash autocomplete for setup.sh

Options:
  -u, --uninstall  Remove autocompletion from BASH_COMPLETION_USER_DIR
  -h, --help       Show this message

EOF
    exit 0
}

uninstall_completions() {
    if [[ -f "$completion_file" ]]; then
        rm "$completion_file"
        echo "Autocomplete removed from $completion_file"
    else
        echo "No autocomplete file to remove."
    fi
    exit 0
}

# Parse options
for arg in "$@"; do
    case "$arg" in
        -h|--help) usage ;;
        -u|--uninstall) uninstall_completions ;;
    esac
done

cat > "$completion_file" <<EOF
#!/usr/bin/env bash
_setup_completion() {
    local cur prev
    cur="\${COMP_WORDS[COMP_CWORD]}"
    prev="\${COMP_WORDS[COMP_CWORD-1]}"
    local cmds="$cmds"
    local options="-h --help -n -y"

    if [[ "\$cur" == -* ]]; then
        COMPREPLY=( \$(compgen -W "\$options" -- "\$cur") )
    else
        if [[ \$COMP_CWORD -eq 1 ]]; then
            COMPREPLY=( \$(compgen -W "\$cmds" -- "\$cur") )
        else
            COMPREPLY=()
        fi
    fi
}
complete -F _setup_completion setup.sh
EOF

echo "Autocomplete installed to $completion_file."
echo "Run 'source $completion_file' or restart your shell to enable it."

