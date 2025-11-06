# buddy.config

Extensible setup script to quickly commission myself a personal computing device.

## Getting Started

1. **Clone the repository:**

   ```sh
   git clone https://github.com/BadrChoubai/buddy.config.git
   cd buddy.config
   ```

2. **Run the setup script:**

   ```sh
   ./setup.sh
   ```

3. **Follow the prompts to complete configuration.**

## Usage

```text
Usage: ./setup_v2.sh <COMMAND> [OPTIONS]

Provides utility commands for configuring your development environment

Available Commands:
  clean           - Remove untracked apps and packages
  dotfiles        - create symlinks for user dotfiles
  help            - Show help message
  install         - Install configured apps and packages
  version         - Show version info

Options:
  -h, --help      - Print this message
```

## Customization

- **Package Management:**  
  The setup script reads from two files:
  - `.pkgs` for apt packages
  - `.apps` for snap packages
    To change which packages are installed, simply edit these files and add or remove package names as needed.

- **Further Customization:**  
  You can also modify the scripts or configuration files in this repository to further personalize the environment to your preferences. Review script variables and settings before execution.

  Here is a detailed breakdown of how **buddy.config** tracks installed apps and packages using lockfile(s), and how it works under the hood:

### Core Concepts

- **Configuration files:**
  - `.pkgs`: List of apt packages for installation
  - `.apps`: List of snap apps for installation

- **Lockfiles:**
  - `.pkgs.lock`: Tracks which apt packages have been successfully installed
  - `.apps.lock`: Tracks which snap apps have been successfully installed

---

### Installation Workflow

```shell name=cmd/install.sh url=https://github.com/BadrChoubai/buddy.config/blob/9672e5a71fb3b84cca5a007c9a983a42b1c41d2e/cmd/install.sh
# Touch lockfiles and config if missing
touch "$dot_pkgs" "$dot_apps" "$installed_pkgs" "$installed_apps"

# Compute packages/apps to install: what's listed in (.pkgs/.apps) but **not** in (.pkgs.lock/.apps.lock)
TO_INSTALL_PKGS=$(comm -13 <(sort "$installed_pkgs") <(sort "$dot_pkgs"))
TO_INSTALL_APPS=$(comm -13 <(sort "$installed_apps") <(sort "$dot_apps"))

# For each missing package/app, install it, and **append its name to the corresponding lockfile** when successful.
install_missing() {
    ...
    echo "$to_install" | while read -r item; do
        ...
        if $install_cmd "$item"; then
            echo "$item" >> "$lock_file"
        fi
    done
}
...
# At the end: sort and deduplicate lockfiles, preserving only confirmed installs
sort -u -o "$installed_pkgs" "$installed_pkgs"
sort -u -o "$installed_apps" "$installed_apps"
```

- When running the install command:
  1. The script reads your desired state from `.pkgs` and `.apps`.
  2. It compares these with the existing lockfiles.
  3. Apps/packages _present in config but missing from lockfiles_ are installed.
  4. After a successful install, their names are appended to the lockfile, ensuring the system knows what's been installed.

---

### Clean/Uninstall Workflow

```shell name=cmd/clean.sh url=https://github.com/BadrChoubai/buddy.config/blob/9672e5a71fb3b84cca5a007c9a983a42b1c41d2e/cmd/clean.sh
# Apps/packages to remove: in .apps.lock/.pkgs.lock, but NOT in .apps/.pkgs
TO_REMOVE_PKGS=$(comm -23 <(sort "$installed_pkgs") <(sort "$dot_pkgs"))
TO_REMOVE_APPS=$(comm -23 <(sort "$installed_apps") <(sort "$dot_apps"))

remove_unconfigured() {
    ...
    echo "$to_remove" | while read -r item; do
        ...
        $uninstall_cmd "$item"
    done
}

# After uninstall, **remove the uninstalled items from lockfiles**: only tracked apps remain
sort "$installed_pkgs" | grep -vxFf <(echo "$TO_REMOVE_PKGS") > "$installed_pkgs.tmp" && mv "$installed_pkgs.tmp" "$installed_pkgs"
sort "$installed_apps" | grep -vxFf <(echo "$TO_REMOVE_APPS") > "$installed_apps.tmp" && mv "$installed_apps.tmp" "$installed_apps"
```

- When running the clean command:
  1. It finds items currently tracked in lockfiles but no longer present in your desired configuration.
  2. These are uninstalled.
  3. The lockfiles are then updated to _exclude_ what was just removed, preserving a clean, accurate install record.

---

### Summary

- **buddy.config** maintains a live record of what's installed via lockfiles (`.pkgs.lock`, `.apps.lock`).
- On **install**, it adds newly installed items to the lockfile.
- On **clean**, it removes items from the lockfile after uninstall.
- This mechanism ensures reproducibility: you can reconstruct your system state, and always know which packages/apps have actually been provisioned versus what’s just desired.

## Author

Maintained by [BadrChoubai](https://github.com/BadrChoubai).
