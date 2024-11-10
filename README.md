# AutoYADM

AutoYADM is a small shell utility to automate the process of managing dotfiles with [YADM](https://github.com/yadm-dev/yadm) by allowing the user to define a list of files & directories to be automatically added, committed and pushed whenever the script is run. **Most notably, AutoYADM accounts for newly created files previously untracked by YADM.**

## Installation

Simply clone the repository:

```Bash
git clone git@github.com:ficcdaf/autoyadm.git
```

You may consider adding aliases to your shell configuration:

```Bash
alias autoyadm="/path/to/autoyadm/autoyadm.sh"
alias yadmadd="/path/to/autoyadm/yadmadd.sh"
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

> _Both scripts and the `tracking` file **must** be in the same directory._

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

To remove a target from tracking, simply delete it from the `tracking` file.

### Committing & Pushing

To automatically commit and add your tracking targets, use `autoyadm.sh`:

```Bash
$ autoyadm
```

By default, 
