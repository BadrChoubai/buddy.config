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

Installs and configures your development environment

Available Commands:
  clean           - Remove untracked apps and packages
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

## Author

Maintained by [BadrChoubai](https://github.com/BadrChoubai).
