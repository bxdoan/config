#!/usr/bin/env bash

s=$BASH_SOURCE ; s=$(dirname "$s") ; s=$(cd "$s" && pwd) ; SCRIPT_HOME="$s"  # get SCRIPT_HOME=executed script's path, containing folder, cd & pwd to get container path
pg="gc_postgres_dn"
to="$1"
if [[ $OSTYPE == 'darwin'* ]]; then
  pipenv="/opt/homebrew/bin/pipenv"
  your_ip="localhost"
else
  your_ip=$(docker inspect ${pg} | grep -oP '(?<="IPAddress": ")[^"]*' | head -n1)
  [ -x pipenv ] && pipenv='pipenv' || pipenv="$HOME/.pyenv/shims/pipenv"
fi
echo "Your IP ${pg} is ${your_ip}"
value="$your_ip;$to"

_() {
    local SH=$(cd `dirname $BASH_SOURCE` && pwd)
    local AH=$(cd "$SH/../src" && pwd)
    printf "go to %s and exe %s\n" "$to" "$AH/setup_ipaddress.py"
    $pipenv run python "$AH/setup_ipaddress.py" $value
}
    eval _