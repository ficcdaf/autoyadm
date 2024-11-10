# AutoYADM

AutoYADM is a small shell utility to automate the process of managing dotfiles with [YADM](https://github.com/yadm-dev/yadm) by allowing the user to define a list of files & directories to be automatically added, committed and pushed whenever the script is run. **Most notably, AutoYADM accounts for newly created files previously untracked by YADM.**

## Features

- Configure a list of files & directories to be automatically tracked by YADM
- Tracked directories will also track any new files inside them!
- Automatically add, commit, and push tracked paths

## Installation

Simply clone the repository:

```Bash
git clone git@github.com:ficcdaf/autoyadm.git
```

You may consider adding aliases to your shell configuration:

```Bash
alias autoyadm="/path/to/autoyadm/autoyadm.sh"
alias yadmadd="/path/to/autoyadm/yadmadd.sh"
# To enable automatic pushing:
alias yadmadd="AUTOYADMPUSH=1 /path/to/autoyadm/yadmadd.sh"
```

<details>
<summary>Click to see dependencies</summary>

- [YADM](https://github.com/yadm-dev/yadm)
- `git`
- Bash/Zsh
- `openssh` (optional)

</details>

## Usage

> Note: The following assumes you have created shell aliases to the two scripts. You may, of course, simply call them directly.

### Tracking

AutoYADM maintains a list of files and directories for automatic tracking. _**All** children of tracked directories will be tracked, including newly created, previously untracked files._ For example, if you add your Neovim configuration at `~/.config/nvim` to tracking, then any new files you create inside that folder will automatically be added and committed by AutoYADM.

> _Both scripts and the `tracked` file **must** be in the same directory._

> **Important**: Symlinks are _**not**_ added; this is to avoid conflicts with `yadm alt`

The tracking file contains the paths to tracked files & directories **relative to $HOME**. For example:

```
.bashrc
.config/nvim
```

To add paths to be tracked, you may use `yadmadd.sh`. Any valid absolute or relative path should work.

```Bash
$ yadmadd ~/.bashrc
$ yadmadd /home/username/.bashrc
# Relative paths work too.
$ yadmadd ../../.bashrc
# You may supply any number of paths as arguments.
$ yadmadd .bashrc .zshrc .config/nvim
```

To remove a target from tracking, simply delete it from the `tracked` file.

> Note: `tracked` is in the `.gitignore` of this repository. If you want to add it to tracking, you will need to remove the `tracked` entry from `.gitignore`. Removing `.git` is not sufficient because YADM respects any `.gitignore` file it encounters.

### Committing & Pushing

To automatically add and commit your tracking targets, use `autoyadm.sh`:

```Bash
$ autoyadm
```

By default, automatic pushing is disabled. You can enable it with an environment variable:

```Bash
$ export AUTOYADMPUSH=1
$ autoyadm
# Or you can combine these into one line:
$ AUTOYADMPUSH=1 autoyadm
```

> Note: For auto push to work, ssh-agent must be enabled, and the environment file needs to exist inside `~/.ssh`. Furthermore, you must have SSH setup with your git host.

### Calling AutoYADM Automatically

By default, AutoYADM only runs when the user calls it explicitly. If you want to automate this process, you are responsible for setting it up yourself. You may consider configuring a cron job for this. The following example will run AutoYADM every 15 minutes, with automatic push enabled, appending its output to a log file:

```Bash
*/15 * * * * AUTOYADMPUSH=1 /path/to/autoyadm/audoyadm.sh >> /path/to/log/file.log
```

If you are on Arch Linux, you can follow these instructions to set up the cron job:

```Bash
# Install a cron daemon if you
# don't already have one.
$ sudo pacman -S cronie
# This command will open your $EDITOR,
# you may paste the above cron job configuration here
# and save the file to apply your changes.
$ crontab -e
# Don't forget to enable cronie.service:
$ systemctl enable cronie
$ systemctl start cronie
```

## Feature Roadmap

- [ ] Allow custom `tracked` file location & name
- [ ] Optionally allow symlinks only if they are explicitly added to tracking

## Contributing

Contributions are very welcome. This is a very small and simple script, but if you have some improvements or new features, please feel free to submit a PR.
