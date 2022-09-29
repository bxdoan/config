#!/usr/bin/env bash
STARTTIME=$(date +%s)
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
psql_container=${PSQL_CONTAINER:-postgres_dn}
replicate_home=$HOME/replicate-schema; mkdir -p "${replicate_home}"
directory_listing=/tmp/directory_listing
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
It takes ${GR}${EXE_TIME}${EC} seconds to complete this script...\n"
}

DOCSTRING=cat << EOF
   ./bin/restore-schema-2-docker-psql.sh
EOF

number_file=$(ls -alF "$replicate_home" | grep $CURRENT_TIME | wc -l | awk '{print $1}')
if [[ "$number_file" != *'2'* ]]; then
  # shellcheck disable=SC2059
  download_msg="Download and execute file"

  # get listing from directory sorted by modification date
  ftp -n "$HOST" > $directory_listing <<fin
  quote USER $USER
  quote PASS $PASSWORD
  cd $SOURCE
  ls -t
  quit
fin

  # parse the filenames from the directory listing
  #files_to_get=$(cut -c 2- < /tmp/directory_listing | head -2 | awk '{print $9}' | sort -r)
  # shellcheck disable=SC2153
  files_to_get=$(cut -c "$LS_FILE_OFFSET"- < $directory_listing | head -"$FILES_TO_GET" | awk '{print $9}' | sort -r)
  # make a set of get commands from the filename(s)
  cmd=""
  for f in $files_to_get; do
  echo "$f"
  cmd="${cmd}get $f
  "
  done

  tmp2=$(ftp -n $HOST <<fin
  quote USER $USER
  quote PASS $PASSWORD
  cd $SOURCE
  $cmd
  quit
fin
)

  for f in $files_to_get; do
    echo "copy file from $f to $replicate_home/"
    # shellcheck disable=SC2086
    mv ${f} "${replicate_home}"/
  done

  rm -f /tmp/directory_listing
else
  download_msg="No download and execute existing file in $replicate_home"
  files_to_get=$(ls -alF "$replicate_home" | grep "$CURRENT_TIME" | awk '{print $9}' | sort -r)
fi

# restore script files to psql db
# drop schema then re-create
# docker exec -it gc_postgres_dn psql -w -U postgres -d atlas  -c 'DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;'
docker exec -it "${psql_container}" psql -w -U postgres -d atlas  -c 'DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;'
# grant permission for schema
# docker exec -it gc_postgres_dn psql -w -U postgres -d atlas  -c 'GRANT ALL ON SCHEMA public TO public; GRANT ALL ON SCHEMA public TO postgres;'
docker exec -it "${psql_container}" psql -w -U postgres -d atlas  -c 'GRANT ALL ON SCHEMA public TO public; GRANT ALL ON SCHEMA public TO postgres;'

for f in $files_to_get; do
    # copy script to container
    tmp_f="$replicate_home/$f"
    psql_container_root="$psql_container:/root/$f"
    echo "copy file from $tmp_f to $psql_container_root"
    docker cp "${tmp_f}" "${psql_container_root}"

    # run scripts
    printf "execute file ${GR}%s${EC}\n" "$f"
    if [[ "$f" == *"-stamp-"* ]]; then
       # shellcheck disable=SC1079
       docker exec -it "${psql_container}" psql -w -U postgres -d atlas  -c 'delete from alembic_version'
       printf "clear alembic_version table first\n"
    fi
    # docker exec -it gc_postgres_dn psql -w -U postgres -d atlas  -f "/root/alembic-stamp-20220913050001.sql"
    docker exec -it "${psql_container}" psql -w -U postgres -d atlas  -f "/root/${f}"
done

p_alembic_version=$(docker exec -it "${psql_container}" psql -w -U postgres -d atlas  -c 'select * from alembic_version' | sed -n '3p')

DIR_ATLAS=$1
if [[ -z $DIR_ATLAS ]]; then DIR_ATLAS="$PWD/.."; fi

UPGRADE_HEAD=$2
if [[ $UPGRADE_HEAD == '-up' ]]; then
  cd "$DIR_ATLAS"
  pipenv run alembic upgrade head
fi

alembic_version=$(docker exec -it "${psql_container}" psql -w -U postgres -d atlas  -c 'select * from alembic_version' | sed -n '3p')
printf "
    ${GR}INFO RESTORE SCHEMA AND UPGRADE HEAD${EC}
Number file downloaded today ${GR}%s${EC}: ${GR}%s${EC}
%s
${GR}PRODUCTION${EC} alembic version: ${GR}%s${EC}
${GR}HEAD${EC} alembic version:       ${GR}%s${EC}\n" "$CURRENT_TIME" "$number_file" "$download_msg" "${p_alembic_version}" "${alembic_version}"
print_exe_time "${STARTTIME}"
