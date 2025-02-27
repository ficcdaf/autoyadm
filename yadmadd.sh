#!/bin/bash

# This script takes file or directories as
# arguments and appends them to the "tracked"
# file, for use by autoyadm.sh

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

AYE="AutoYADM Error:"
AYM="AutoYADM:"

# We check if any arguments have been provided
if [ $# -eq 0 ]; then
  echo "$AYE $0 <file_or_directory> [<file_or_directory> ...]"
  exit 1
fi

# We loop through arguments
for arg in "$@"; do
  # check if current arg is a real path
  if [ ! -e "$arg" ]; then
    echo "$AYE '$arg' is not a valid path."
    continue
  fi
  # get its absolute path
  abs=$(realpath "$arg")
  # Don't allow direct homedir or config dir
  if [[ "$abs" == "$HOME" || "$abs" == "$HOME/.config" ]]; then
    echo "$AYM Path cannot be home directory or config directory."
    exit 1
  fi
  # check if /inside/ home dir
  if [[ "$abs" == "$HOME"* ]]; then
    # convert to path relative to ~
    rel=${abs#"$HOME/"}
    # append to tracked file
    echo "$rel" >>"$(get_tracked_file)"
    echo "$AYM Tracking $HOME/$rel as '$rel'"
  else
    echo "$AYM Path must be inside the home directory."
    exit 1
  fi
done
