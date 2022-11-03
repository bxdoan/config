#!/usr/bin/env bash
STARTTIME=$(date +%s)
f_debug='f'
# shellcheck disable=SC2006
# shellcheck disable=SC2128
# shellcheck disable=SC2034
# shellcheck disable=SC2046
# shellcheck disable=SC2006
# shellcheck disable=SC2034
PWD=`cd $(dirname "$BASH_SOURCE") && pwd`; CODE=$(cd "$PWD"/.. && pwd)
set -e  # halt if error

if [ -f "$PWD"/.env-restore-schema ]; then
    # Load Environment Variables from .env-restore-schema
    # shellcheck disable=SC2046
    export $(cat "$PWD"/.env-restore-schema | grep -v '#' | sed 's/\r$//' | awk '/=/ {print $1}' )
fi

# Alias some config
pg=${PSQL_CONTAINER:-postgres_dn}
replicate_home=$HOME/replicate-schema; mkdir -p "${replicate_home}"
directory_listing=/tmp/directory_listing
# shellcheck disable=SC2006
CURRENT_TIME=`date +%Y%m%d`
#region printing util
EC='\033[0m'    # end coloring
HL='\033[0;33m' # high-lighted color
ER='\033[0;31m' # red color

CM='\033[0;32m' # comment color
GR='\033[0;32m' # green color
WH='\033[0;37m' # white color
function print_exe_time() {
    STARTTIME=${1}
    ENDTIME=$(date +%s)
    EXE_TIME=$((${ENDTIME} - ${STARTTIME}))
    printf "
It takes ${GR}%s${EC} seconds to complete this script...\n" " ${EXE_TIME}"
}

function print_debug() {
  if [[ $f_debug == 't' ]]; then
    printf "${1}\n"
  fi
}

number_file=$(ls -alF "$replicate_home" | grep -c "$CURRENT_TIME" | awk '{print $1}')
if [[ "$number_file" != *'2'* ]]; then
  # shellcheck disable=SC2059
  download_msg="Download and execute file"

  # get listing from directory sorted by modification date
  if [[ $OSTYPE == 'darwin'* ]]; then
    ftp -n "$HOST" > $directory_listing <<fin
    quote USER $USER
    quote PASS $PASSWORD
    cd $SOURCE
    pass
    ls -t
    quit
fin
  else
    ftp -n "$HOST" > $directory_listing <<fin
    quote USER $USER
    quote PASS $PASSWORD
    cd $SOURCE
    ls -t
    quit
fin
  fi


  # parse the filenames from the directory listing
  # shellcheck disable=SC2153
  files_to_get=$(cut -c "$LS_FILE_OFFSET"- < $directory_listing | head -"$FILES_TO_GET" | tail -n 2 | awk '{print $9}' | sort -r)
  # make a set of get commands from the filename(s)
  cmd=""
  for f in $files_to_get; do
  echo "$f"
  cmd="${cmd}get $f
  "
  done

  if [[ $OSTYPE == 'darwin'* ]]; then
    tmp2=$(ftp -n $HOST <<fin
    quote USER $USER
    quote PASS $PASSWORD
    pass
    cd $SOURCE
    $cmd
    quit
fin
)
  else
    tmp2=$(ftp -n $HOST <<fin
    quote USER $USER
    quote PASS $PASSWORD
    cd $SOURCE
    $cmd
    quit
fin
)
  fi


  for f in $files_to_get; do
    print_debug "download file $f to $replicate_home/"
    # shellcheck disable=SC2086
    mv ${f} "${replicate_home}"/
  done

else
  download_msg="No download and execute existing file in $replicate_home"
  files_to_get=$(ls -alF "$replicate_home" | grep "$CURRENT_TIME" | awk '{print $NF}' | sort -r)
fi

function drop_schema() {
  # restore script files to psql db
  # drop schema then re-create
  docker exec -it "${pg}" psql -w -U postgres -d atlas  -c 'DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;' >& /dev/null
  # grant permission for schema
  docker exec -it "${pg}" psql -w -U postgres -d atlas  -c 'GRANT ALL ON SCHEMA public TO public; GRANT ALL ON SCHEMA public TO postgres;' >& /dev/null
}

function execute_file() {
  for f in $files_to_get; do
      # copy script to container
      tmp_f="$replicate_home/$f"
      pg_root="$pg:/root/$f"
      print_debug "copy file from $tmp_f to $pg_root"
      docker cp "${tmp_f}" "${pg_root}"

      # run scripts
      print_debug "execute file ${GR}%s${EC}" "$f"
      if [[ "$f" == *"-stamp-"* ]]; then
         # shellcheck disable=SC1079
         docker exec -it "${pg}" psql -w -U postgres -d atlas  -c 'delete from alembic_version' >& /dev/null
         print_debug "clear ${GR}alembic_version${EC} table first"
      fi
      docker exec -it "${pg}" psql -w -U postgres -d atlas  -f "/root/${f}" >& /dev/null
  done
}

drop_schema
execute_file
p_alembic_version=$(docker exec -it "${pg}" psql -w -U postgres -d atlas  -c 'select * from alembic_version' | sed -n '3p')

DIR_ATLAS=$1
if [[ -z $DIR_ATLAS ]]; then DIR_ATLAS="$PWD/.."; fi

UPGRADE_HEAD=$2
if [[ $UPGRADE_HEAD == '-up' ]]; then
  cd "$DIR_ATLAS"
  pipenv run alembic upgrade head  >& /dev/null
fi

alembic_version=$(docker exec -it "${pg}" psql -w -U postgres -d atlas  -c 'select * from alembic_version' | sed -n '3p')
printf "
    ${GR}INFO RESTORE SCHEMA AND UPGRADE HEAD${EC}
Number file downloaded today ${GR}%s${EC}: ${GR}%s${EC}
%s
${GR}PRODUCTION${EC} alembic version: ${GR}%s${EC}
${GR}HEAD${EC} alembic version:       ${GR}%s${EC}" "$CURRENT_TIME" "$number_file" "$download_msg" "${p_alembic_version}" "${alembic_version}"
print_exe_time "${STARTTIME}"
