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

> Additionally, you can make changes to `.env` to use non-default values for system
> configuration

## Usage

```text

Usage: ./setup_v2.sh <COMMAND> [OPTIONS]

Provides utility commands for configuring your development environment

Available Commands:
  clean           - Remove untracked apps and packages
  config          - Print command-line configuration values
  dotfiles        - create symlinks for user dotfiles
  help            - Show help message
  install         - Install configured apps and packages
  templates       - initialize XDG_TEMPLATE_DIR
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

### Summary

- **buddy.config** maintains a live record of what's installed via lockfiles (`.pkgs.lock`, `.apps.lock`).
- On **install**, it adds newly installed items to the lockfile.
- On **clean**, it removes items from the lockfile after uninstall.
- This mechanism ensures reproducibility: you can reconstruct your system state, and always know which packages/apps have actually been provisioned versus what’s just desired.

## Author

Maintained by [BadrChoubai](https://github.com/BadrChoubai).
