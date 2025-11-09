# buddy.config

**buddy.config** is an extensible setup script designed to quickly provision a personal computing environment. It helps you install packages, manage dotfiles, and configure your system reproducibly.

---

## Getting Started

1. **Clone the repository:**

   ```sh
   git clone https://github.com/BadrChoubai/buddy.config.git
   cd buddy.config
   ```

   > If you don’t have Git installed:
   >
   > ```sh
   > sudo apt install git
   > ```

2. **Run the setup script:**

   ```sh
   ./setup.sh
   ```

3. **Follow the prompts** to complete your configuration.

> You can also edit the `.env` file to override default values for system configuration.

---

## Usage

```
Usage: ./setup_v2.sh <COMMAND> [OPTIONS]

Provides utility commands for configuring your development environment

Available Commands:
  autocomplete    - Installs Bash autocomplete for setup.sh
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

---

## Customization

### Package Management

- **APT packages:** `.pkgs`
- **Snap apps:** `.apps`

> Edit these files to add or remove packages/apps as needed. The setup script reads from these files during provisioning.

### Environment Configuration

- `.env` contains environment variables used by the commands.
- Modify `.env` to adjust paths, repository URLs, or other configurable settings.

### Further Customization

- You can extend or modify the scripts to tailor the environment to your preferences.
- Review script variables and command logic before execution to ensure desired behavior.

---

## Core Concepts

### Configuration Files

| File    | Purpose                                   |
| ------- | ----------------------------------------- |
| `.env`  | Environment variables used by the scripts |
| `.pkgs` | List of APT packages to install           |
| `.apps` | List of Snap applications to install      |

### Lockfiles

| File         | Purpose                                    |
| ------------ | ------------------------------------------ |
| `.pkgs.lock` | Tracks successfully installed APT packages |
| `.apps.lock` | Tracks successfully installed Snap apps    |

> Lockfiles ensure reproducibility. They allow you to track the actual installed state versus the desired packages/apps listed in `.pkgs` and `.apps`.

---

## How It Works

- **Install Command:**
  Installs packages and apps, and adds them to the corresponding lockfiles.

- **Clean Command:**
  Removes packages/apps and updates lockfiles accordingly.

- This mechanism ensures your system state is **reproducible** and transparent.

---

## Author

Maintained by [BadrChoubai](https://github.com/BadrChoubai).
