#!/usr/bin/env bash

s=$BASH_SOURCE ; s=$(dirname "$s") ; s=$(cd "$s" && pwd) ; SCRIPT_HOME="$s"  # get SCRIPT_HOME=executed script's path, containing folder, cd & pwd to get container path
to="$1"
if [[ -f "$HOME/.pyenv/shims/pipenv" ]]; then
  [ -x pipenv ] && pipenv='pipenv' || pipenv="$HOME/.pyenv/shims/pipenv"
elif [[ -f "$HOME/.local/bin/pipenv" ]]; then
  [ -x pipenv ] && pipenv='pipenv' || pipenv="$HOME/.local/bin/pipenv"
elif [[ -f "/opt/homebrew/bin/pipenv" ]]; then
  pipenv="/opt/homebrew/bin/pipenv"
else
  echo "pipenv application not found"
  exit 1
fi

_() {
    local SH=$(cd `dirname $BASH_SOURCE` && pwd)
    local AH=$(cd "$SH/../src" && pwd)
    printf "go to %s and exe %s\n" "$to" "$AH/clean.py"
    $pipenv run python "$AH/clean.py" $to
}
    eval _