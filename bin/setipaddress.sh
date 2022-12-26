#!/usr/bin/env bash

s=$BASH_SOURCE ; s=$(dirname "$s") ; s=$(cd "$s" && pwd) ; SCRIPT_HOME="$s"  # get SCRIPT_HOME=executed script's path, containing folder, cd & pwd to get container path
pg="gc_postgres_dn"
to="$1"
your_ip=$(docker inspect ${pg} | grep -oP '(?<="IPAddress": ")[^"]*' | head -n1)
echo "Your IP ${pg} is ${your_ip}"
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
value="$your_ip;$to"

_() {
    local SH=$(cd `dirname $BASH_SOURCE` && pwd)
    local AH=$(cd "$SH/../src" && pwd)
    printf "go to %s and exe %s\n" "$to" "$AH/setup_ipaddress.py"
    $pipenv run python "$AH/setup_ipaddress.py" $value
}
    eval _