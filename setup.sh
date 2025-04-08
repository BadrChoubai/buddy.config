#!/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Source logging and argument parsing
. "$script_dir/parse_args.sh" "$@"
. "$script_dir/log.sh"

not=("docker" "packages")
not_pattern="$(IFS='|'; echo "${not[*]}")"

installs=$(find "$script_dir/installs" -mindepth 1 -maxdepth 1 -executable \
    | sort \
    | grep -Ev "/($not_pattern)$")

uninstalls=$(find "$script_dir/uninstalls" -mindepth 1 -maxdepth 1 -executable \
    | sort \
    | grep -Ev "/($not_pattern)$")

if [[ -z "$XDG_CONFIG_HOME" ]]; then
    log "WARN" "No XDG_CONFIG_HOME found, using ~/.config"
    export XDG_CONFIG_HOME="$HOME/.config"
fi

prompt() {
    if [[ "$action" == "install" || "$action" == "uninstall" ]]; then
        log "INFO" "You are about to $action your environment:"

        echo ""
        echo "ARGS:"
        echo "    MODE: \"$action\""
        echo "    EXCLUDES: \"${not[*]}\""
        echo ""
        
        # Confirmation prompt
        read -p "Continue? (y/n) " CONFIRM
        if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
            log "INFO" "$action aborted."
            exit 1
        fi
    fi
}


update_files() {
    log "INFO" "Copying files from: $1"

    pushd "$1" &> /dev/null
    for c in $(find . -mindepth 1 -maxdepth 1 -type d); do
        directory=${2%/}/${c#./}
        log "INFO" "Removing: $directory"

        if [[ -d "$directory" ]]; then
            [[ $DRY_RUN == "0" ]] && rm -rf "$directory"
        fi
        
        log "INFO" "Copying: $c to $2"
        [[ $DRY_RUN == "0" ]] && cp -r "./$c" "$2"

    done
    popd &> /dev/null
}

copy() {
    log "INFO" "Removing: $2"
    [[ $DRY_RUN == "0" ]] && rm -f "$2"
    
    log "INFO" "Copying: $1 to $2"
    [[ $DRY_RUN == "0" ]] && cp "$1" "$2"
}

install() {
    log "INFO" "Installing packages and linking environment"
    while IFS= read -r s; do
        log "INFO" "Running script: $s"
        [[ "$DRY_RUN" == "0" ]] && "$s"
    done <<< "$installs"
}

uninstall() {
    log "INFO" "Uninstalling packages and removing environment"
    while IFS= read -r s; do
        log "INFO" "Running script: $s"
        [[ "$DRY_RUN" == "0" ]] && "$s"
    done <<< "$uninstalls"

    [[ "$DRY_RUN" == "0" ]] && sudo apt -y autoremove
    [[ "$DRY_RUN" == "0" ]] && sudo apt-get -y autoremove
}

down() {
    log "INFO" "Removing existing configuration files..."
    [[ "$DRY_RUN" == "0" ]] && rm -f "$HOME/.alacritty.toml" "$HOME/.aliases" "$HOME/.bashrc" "$HOME/.zshrc"
}

up() {
    log "INFO" "copying configuration files to $XDG_CONFIG_HOME..."

    update_files "$(pwd)/env/.config" "$XDG_CONFIG_HOME"

    copy "$(pwd)/env/.aliases" "$HOME/.aliases"
    copy "$(pwd)/env/.bashrc" "$HOME/.bashrc"
    copy "$(pwd)/env/.zshrc" "$HOME/.zshrc"
    copy "$(pwd)/env/.zsh_profile" "$HOME/.zsh_profile"
}

refresh() {
    log "INFO" "Refreshing configuration files only"
    down
    up
}

# Execute the requested action
if [[ "$action" == "install" || "$action" == "uninstall" || "$action" == "refresh"  ]]; then
    prompt
    for n in "${not[@]}"; do
        log "WARN" "Not Modifying: $n"
    done

    case "$action" in
        install)
            . "$script_dir/pre-install.sh"
            install
            ;;
        uninstall)
            uninstall
            ;;
        refresh)
            refresh
            ;;
    esac
    exit
else
    log "ERROR" "Unknown action: $action"
    exit 1
fi

