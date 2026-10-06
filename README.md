# buddy.config

Dotfiles and package list for my development environment, with a small
script to install packages and link configs into `$HOME`.

## Layout

| Path            | Purpose                                                    |
| --------------- | ---------------------------------------------------------- |
| `env/`          | Dotfiles, laid out as they appear under `$HOME`            |
| `.pkgs`         | Packages to install, one per line (`#` lines are skipped)  |
| `.env`          | Settings, such as `PACKAGE_MANAGER` (`dnf`, `apt`, `brew`) |
| `provision.sh`  | Entry point that runs a command from `cmd/`                |

## Commands

```bash
./provision.sh <command> [options]
```

| Command    | Description                                     |
| ---------- | ----------------------------------------------- |
| `install`  | Install packages from `.pkgs` that are missing  |
| `dotfiles` | Symlink `env/` into `$HOME` with GNU Stow       |
| `config`   | Print `.env`, or one value: `config <KEY>`      |
| `help`     | List commands                                   |

Options: `-n` / `--dry-run` shows what would happen, `-y` / `--skip-prompt`
skips confirmation, `-h` / `--help` shows a command's usage.

## New machine

```bash
git clone <repo> ~/buddy.config
cd ~/buddy.config
./provision.sh install
./provision.sh dotfiles
```

`install` also installs `stow`, which `dotfiles` needs. If `dotfiles`
reports a conflict, a real file is in the way (often the `~/.zshrc` a
fresh install creates); move it aside and run it again.

These are not installed by the scripts yet. The shell starts without them,
but their features are missing until they're set up:

- Neovim, installed to `/usr/local`
- [oh-my-zsh](https://ohmyz.sh), in `~/.oh-my-zsh`
- [nvm](https://github.com/nvm-sh/nvm), in `~/.config/nvm`
- Go (`/usr/local/go`) and Rust (`~/.cargo`)

## Day to day

- **Edit a config:** edit it in place; `~/.config/...` links into `env/`.
- **Add a config:** put it under `env/` at its path relative to `$HOME`,
  then run `./provision.sh dotfiles`.
- **Remove a config:** delete it from `env/`, then run
  `./provision.sh dotfiles` to remove the link.
- **Add a package:** add it to `.pkgs`, then run `./provision.sh install`.
- **Remove a package:** delete it from `.pkgs` and uninstall it with your
  package manager.

If you move the repo, run `./provision.sh dotfiles` again to fix the links.

`.pkgs` uses Fedora package names; other package managers may need
different names.
