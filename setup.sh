#!/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Source logging and argument parsing
. "$script_dir/log.sh"
. "$script_dir/parse_args.sh" "$@"

not=("docker" "packages")
not_pattern="$(IFS='|'; echo "${not[*]}")"

installs=$(find "$script_dir/installs" -mindepth 1 -maxdepth 1 -executable \
    | sort \
    | grep -Ev "/($not_pattern)$")

uninstalls=$(find "$script_dir/uninstalls" -mindepth 1 -maxdepth 1 -executable \
    | sort \
    | grep -Ev "/($not_pattern)$")

if [[ -z "$XDG_CONFIG_HOME" ]]; then
    log "No XDG_CONFIG_HOME found, using ~/.config"
    export XDG_CONFIG_HOME="$HOME/.config"
fi

prompt() {
    if [[ "$action" == "install" ]]; then
        log "You are about to install your environment:"

        echo ""
        echo "ARGS:"
        echo "    MODE: \"$action\""
        echo "    EXCLUDES: \"${not[*]}\""
        echo ""
        
        # Confirmation prompt
        read -p "Continue? (y/n) " CONFIRM
        if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
            log "Installation aborted."
            exit 1
        fi
    elif [[ "$action" == "uninstall" ]]; then
        log "You are about to uninstall your environment:"

        echo ""
        echo "ARGS:"
        echo "    MODE: \"uninstall\""
        echo "    EXCLUDES: \"${not[*]}\""
        echo ""
        
        # Confirmation prompt
        read -p "Continue? (y/n) " CONFIRM
        if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
            log "Uninstallation aborted."
            exit 1
        fi
        
    fi
}

update_files() {
    log "Copying files from: $1"

    pushd "$1" &> /dev/null
    for c in $(find . -mindepth 1 -maxdepth 1 -type d); do
        directory=${2%/}/${c#./}
        log "Removing: $directory"
        [[ $dry_run == "0" ]] && rm -rf "$directory"
        
        log "Copying: $c to $2"
        [[ $dry_run == "0" ]] && cp -r "./$c" "$2"
    done
    popd &> /dev/null
}

copy() {
    log "Removing: $2"
    [[ $dry_run == "0" ]] && rm -f "$2"
    
    log "Copying: $1 to $2"
    [[ $dry_run == "0" ]] && cp "$1" "$2"
}

install() {
    log "Installing packages and linking environment"
    while IFS= read -r s; do
        log "Running script: $s"
        [[ "$dry_run" == "0" ]] && "$s"
    done <<< "$installs"
}

uninstall() {
    log "Uninstalling packages and removing environment"
    while IFS= read -r s; do
        log "Running script: $s"
        [[ "$dry_run" == "0" ]] && "$s"
    done <<< "$uninstalls"

    [[ "$dry_run" == "0" ]] && sudo apt -y autoremove
    [[ "$dry_run" == "0" ]] && sudo apt-get -y autoremove
}

down() {
    log "Removing existing configuration files..."
    [[ "$dry_run" == "0" ]] && rm -f "$HOME/.alacritty.toml" "$HOME/.aliases" "$HOME/.bashrc" "$HOME/.zshrc"
}

up() {
    update_files "$(pwd)/env/.config" "$XDG_CONFIG_HOME"

    copy "$(pwd)/env/.aliases" "$HOME/.aliases"
    copy "$(pwd)/env/.bashrc" "$HOME/.bashrc"
    copy "$(pwd)/env/.zshrc" "$HOME/.zshrc"
    copy "$(pwd)/env/.zsh_profile" "$HOME/.zsh_profile"
}

refresh() {
    log "Refreshing configuration files only"
    down
    up
}

# Log skipped packages
for n in "${not[@]}"; do
    log "Not Modifying: $n"
done

# Execute the requested action
if [[ "$action" == "install" ]]; then
    prompt $action
    install 
    exit
elif [[ "$action" == "uninstall" ]]; then
    prompt $action
    uninstall 
    exit
elif [[ "$action" == "refresh" ]]; then
    refresh
    exit
fi

