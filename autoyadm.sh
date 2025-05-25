#!/bin/bash

# This script reads tracked paths
# from a file and executes "yadm add"
# on all of them, then creates a timestamped
# commit and pushes the changes.
# Author: Daniel Fichtinger
# License: MIT

AYE="AutoYADM Error:"
AYM="AutoYADM:"

function get_tracked_file {
  if [ -e "$XDG_CONFIG_HOME" ]; then
    if [ ! -f "$XDG_CONFIG_HOME/yadm/tracked" ]; then
      mkdir -p "$XDG_CONFIG_HOME/yadm"
      touch "$XDG_CONFIG_HOME/yadm/tracked"
    fi
    echo "$XDG_CONFIG_HOME/yadm/tracked"
  elif [ -f "$HOME/.config/yadm/tracked" ]; then
    echo "$HOME/.config/yadm/tracked"
  else
    echo "$AYM Please move your tracked file to ~/.config/yadm/tracked."
    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tracked"
  fi
}

# We check not to overwrite the user's env setting
if [ -z "$AUTOYADMPUSH" ] || ((!AUTOYADMPUSH)); then
  AUTOYADMPUSH=0
  echo "$AYM Autopush is disabled."
fi

# Set hostname explicitly because it
# may not be present in this shell environment
if [ -z "$HOST" ]; then
  HOST="$(hostname)"
fi

# check if fd is installed,
# if so we prefer that. Setting this variable
# avoids needing to repeat the check on every
# fd/find invocation.
if command -v fd >/dev/null; then
  FD="true"
else
  FD="false"
fi

# First we read each path from "tracked"
(while read -r relpath; do
  path="$HOME/$relpath"
  # Execute yadm add on each real file
  # if the path points to a directory
  # This ensures symlinks are not added
  if [ -d "$path" ]; then
    if [ "$FD" == "true" ]; then
      # we prefer fd because it respects .ignore and .gitignore
      fd --no-require-git --hidden -t f . "$path" -X yadm add
    else
      find "$path" -type f -exec yadm add {} +
    fi
  # If just a file, we add directly
  elif [ -f "$path" ]; then
    yadm add "$path"
  # If neither file nor dir, something is very wrong!
  else
    echo "$AYE Target $path must be a directory or a file!"
    exit 1
  fi
done) <"$(get_tracked_file)"

# Now we also stage files already tracked by YADM
# that have been renamed or deleted; since the above
# loop will not stage them:

yadm add -u

# Define the location of the ssh-agent environment
sshenv="$HOME/.ssh/environment-$HOST"
if [[ -n $(yadm status --porcelain) ]]; then
  yadm commit -m "AutoYADM commit: $(date +'%Y-%m-%d %H:%M:%S')"
  # Check if the ssh-agent env exists
  if [[ -f "$sshenv" ]]; then
    if ((!AUTOYADMPUSH)); then
      echo "$AYM Pushing disabled, aborting..."
      exit 1
    fi
    # Directive to suppress shellcheck warning
    # shellcheck source=/dev/null
    source "$sshenv"
    echo "$AYM Push successful!"
  else
    echo "$AYE ssh-agent environment not found, aborting push..."
    exit 1
  fi
else
  echo "$AYM Nothing to commit."
fi

yadm push
