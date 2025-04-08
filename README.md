# AutoYADM

AutoYADM is a small shell utility to automate the process of managing dotfiles
with [YADM](https://github.com/yadm-dev/yadm) by allowing the user to define a
list of files & directories to be automatically added, committed and pushed
whenever the script is run. **Most notably, AutoYADM accounts for newly created
files previously untracked by YADM.**

The benefits of this approach:

1. Robust version control thanks to YADM and Git.
2. You won't forget to commit new files in important folders.
3. Maintain control over paths to auto-commit, and paths to only manually
   commit.

I have personally been using AutoYADM to sync my dotfiles between devices
without any problems since October 2024.

## Features

- Configure a list of files & directories to be automatically tracked by YADM.
- Tracked directories will also track any new files inside them!
- Automatically add, commit, and push tracked paths.
- `.ignore` support with `fd`.

## Installation

Simply clone the repository:

```Bash
git clone https://git.sr.ht/~ficd/autoyadm
```

You may consider adding aliases to your shell configuration:

```Bash
alias autoyadm="/path/to/autoyadm/autoyadm.sh"
alias yadmadd="/path/to/autoyadm/yadmadd.sh"
# To enable automatic pushing:
alias autoyadm="AUTOYADMPUSH=1 /path/to/autoyadm/autoyadm.sh"
```

**Dependencies**:

- [YADM](https://github.com/yadm-dev/yadm)
- `git`
- `fd` (optional, but recommended)
  - fallback to `find` otherwise
- `openssh` (required for pushing)

## Usage

> Note: The following assumes you have created shell aliases to the two scripts.
> You may, of course, simply call them directly.

### Tracking

AutoYADM maintains a list of files and directories for automatic tracking.
_**All** children of tracked directories will be tracked, including newly
created, previously untracked files._ For example, if you add your Neovim
configuration at `~/.config/nvim` to tracking, then any new files you create
inside that folder will automatically be added and committed by AutoYADM.

The tracking file is stored in `~/.config/yadm/tracked`. `$XDG_CONFIG_HOME` is
respected. The file will be automatically created if it doesn't already exist.
You can even add it to tracking: `yadmadd ~/.config/yadm/tracked`

> **Important**: Symlinks are _**not**_ added; this is to avoid conflicts with
> `yadm alt`

The tracking file contains the paths to tracked files & directories **relative
to $HOME**. For example:

```
.bashrc
.config/nvim
```

To add paths to be tracked, you may use `yadmadd.sh`. Any valid absolute or
relative path should work.

```Bash
$ yadmadd ~/.bashrc
$ yadmadd /home/username/.bashrc
# Relative paths work too.
$ yadmadd ../../.bashrc
# You may supply any number of paths as arguments.
$ yadmadd .bashrc .zshrc .config/nvim
```

To remove a target from tracking, simply delete it from the `tracked` file.

### Ignoring Certain Files

It's possible to ignore certain patterns inside a folder you're otherwise
tracking with `yadmadd`. For example, suppose you've added `.config/foo`, but
you want to specifically ignore `.config/foo/bar.log`. You can use a `.ignore`
file for this:

```sh
echo "bar.log" > ~/.config/foo/.ignore
```

The `.ignore` file must be in the root of the directory you've added with
`yadmadd`. You also need `fd` available on your `$PATH` for ignoring to work.

### Committing & Pushing

To automatically add and commit your tracking targets, use `autoyadm.sh`:

```Bash
$ autoyadm
```

By default, automatic pushing is disabled. You can enable it with an environment
variable:

```Bash
$ export AUTOYADMPUSH=1
$ autoyadm
# Or you can combine these into one line:
$ AUTOYADMPUSH=1 autoyadm
```

> Note: For auto push to work, ssh-agent must be enabled, and the environment
> file needs to exist inside `~/.ssh`. Furthermore, you must have SSH setup with
> your git host.

### Calling AutoYADM Automatically

By default, AutoYADM only runs when the user calls it explicitly. If you want to
automate this process, you are responsible for setting it up yourself. You may
consider configuring a cron job for this. The following example will run
AutoYADM every 15 minutes, with automatic push enabled, appending its output to
a log file:

```Bash
*/15 * * * * AUTOYADMPUSH=1 /path/to/autoyadm/audoyadm.sh >> /path/to/log/file.log
```

If you are on Arch Linux, you can follow these instructions to set up the cron
job:

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
