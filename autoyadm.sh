#!/bin/bash

# This script reads tracked paths
# from a file and executes "yadm add"
# on all of them, then creates a timestamped
# commit and pushes the changes.

AYE="AutoYADM Error:"
AYM="AutoYADM:"
# We get the absolute path to the script's parent directory.
# TODO: change this to 1. optionally read from an env var, 2. default to .config/autoyadm

# We check not to overwrite the user's env setting
if [ -z "$AUTOYADMDIR" ]; then
  AUTOYADMDIR="$HOME/.config/autoyadm"
  echo "$AYM Using default config directory: $AUTOYADMDIR"
fi
# We check not to overwrite the user's env setting
if [ -z "$AUTOYADMPUSH" ] || ((!AUTOYADMPUSH)); then
  AUTOYADMPUSH=0
  echo "$AYM Autopush is disabled."
fi

# we check if the config directory exists
if [ ! -d "$AUTOYADMDIR" ]; then
  echo "$AYM Specified configuration directory $AUTOYADMDIR does not exist, creating it now..."
  if [ mkdir -p "$AUTOYADMDIR" -eq 0 ]; then
    echo "Directory created successfully."
  else
    echo "Failed to create directory."
  fi

fi

exit 0

# Set hostname explicitly because it
# may not be present in this shell environment
if [ -z "$HOST" ]; then
  HOST="$(hostname)"
fi

# First we read each path from "tracked"
(while read -r relpath; do
  path="$HOME/$relpath"
  # Execute yadm add on each real file
  # if the path points to a directory
  # This ensures symlinks are not added
  if [ -d "$path" ]; then
    find "$path" -type f -exec yadm add {} +
  # If just a file, we add directly
  elif [ -f "$path" ]; then
    yadm add "$path"
  # If neither file nor dir, something is very wrong!
  else
    echo "$AYE Target $path must be a directory or a file!"
    exit 1
  fi
done) <"$AUTOYADMDIR/tracked"

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
