#!/usr/bin/env bash

s=$BASH_SOURCE ; s=$(dirname "$s") ; s=$(cd "$s" && pwd) ; SCRIPT_HOME="$s"  # get SCRIPT_HOME=executed script's path, containing folder, cd & pwd to get container path
pg="gc_postgres_dn"
your_ip=$(docker inspect ${pg} | grep -oP '(?<="IPAddress": ")[^"]*' | head -n1)
echo "Your IP ${pg} is ${your_ip}"

_() {

    local SH=$(cd `dirname $BASH_SOURCE` && pwd)
    echo $SH
    local AH=$(cd "$SH/.." && pwd)
    echo $AH

            cd $AH
                # prepare :pipenv binary
                [ -x pipenv ] && pipenv='pipenv' || pipenv="$HOME/.pyenv/shims/pipenv"
                        PYTHONPATH=`pwd`  $pipenv run python  "$SH/setup_ipaddress.py" $your_ip
}
    eval _