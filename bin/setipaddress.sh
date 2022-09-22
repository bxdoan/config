#!/usr/bin/env bash

s=$BASH_SOURCE ; s=$(dirname "$s") ; s=$(cd "$s" && pwd) ; SCRIPT_HOME="$s"  # get SCRIPT_HOME=executed script's path, containing folder, cd & pwd to get container path
pg="gc_postgres_dn"

if [[ $OSTYPE == 'darwin'* ]]; then
  pipenv="/opt/homebrew/bin/pipenv"
  your_ip="localhost"
else
  your_ip=$(docker inspect ${pg} | grep -oP '(?<="IPAddress": ")[^"]*' | head -n1)
  [ -x pipenv ] && pipenv='pipenv' || pipenv="$HOME/.pyenv/shims/pipenv"
fi
echo "Your IP ${pg} is ${your_ip}"

_() {

    local SH=$(cd `dirname $BASH_SOURCE` && pwd)
    echo $SH
    local AH=$(cd "$SH/.." && pwd)
    echo $AH

            cd $AH
            $pipenv run python  "$SH/setup_ipaddress.py" $your_ip
}
    eval _