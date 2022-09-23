#!/usr/bin/env bash
STARTTIME=$(date +%s)

# Alias some config
PWD=`cd $(dirname "$BASH_SOURCE") && pwd`; CODE=`cd $PWD/.. && pwd`
psql_container=${PSQL_CONTAINER:-gc_postgres_dn}
replicate_home=$HOME/replicate-schema; mkdir -p ${replicate_home}
directory_listing=/tmp/directory_listing

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

set -e  # halt if error

if [ -f "$PWD"/.env-restore-schema ]; then
    # Load Environment Variables from .env-restore-schema
    export $(cat "$PWD"/.env-restore-schema | grep -v '#' | sed 's/\r$//' | awk '/=/ {print $1}' )
fi

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
files_to_get=$(cut -c $LS_FILE_OFFSET- < $directory_listing | head -$FILES_TO_GET | awk '{print $9}' | sort -r)
# make a set of get commands from the filename(s)
cmd=""
for f in $files_to_get; do
echo $f
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
    printf "exec file %s" "$f"
    if [[ "$f" == *"-stamp-"* ]]; then
       # shellcheck disable=SC1079
       docker exec -it "${psql_container}" psql -w -U postgres -d atlas  -c 'delete from alembic_version'
       printf "clear alembic_version table first"
    fi
    # docker exec -it gc_postgres_dn psql -w -U postgres -d atlas  -f "/root/alembic-stamp-20220913050001.sql"
    docker exec -it "${psql_container}" psql -w -U postgres -d atlas  -f "/root/${f}"
done

alembic_version=$(docker exec -it "${psql_container}" psql -w -U postgres -d atlas  -c 'select * from alembic_version' | sed -n '3p')
printf "
alembic_version: ${GR}%s${EC}\n" "${alembic_version}"

print_exe_time ${STARTTIME}
