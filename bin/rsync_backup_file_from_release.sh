#!/usr/bin/env bash
# usage
#./bin/rsync_backup_file_from_release.sh /tmp/don/ phoenix_file.gz

EC='\033[0m'    # end coloring
HL='\033[0;33m' # high-lighted color
ER='\033[0;31m' # red color
CM='\033[0;32m' # comment color
GR='\033[0;32m' # green color
WH='\033[0;37m' # white color
STARTTIME=$(date +%s)
function print_exe_time() {
    STARTTIME=${1}
    ENDTIME=$(date +%s)
    EXE_TIME=$((${ENDTIME} - ${STARTTIME}))
    printf "
It takes ${GR}%s${EC} seconds to complete this script...\n" " ${EXE_TIME}"
}

function ssh_cmd() {
    printf "${GR}$1${EC}\n"
    ssh jingr@release.s.gigacover.com "$1"
}

# download file from release to local
remote_tmp="/tmp/`whoami`"

POSTGRES_USER='postgres'
CONTAINER_NAME="$1_c"
DATABASE_NAME="$1_m"
if [ "$1" = "phoenix" ]; then
  CONTAINER_NAME="phoenix_db_c"
  DATABASE_NAME='phoenix'
fi

remotefilepath="$remote_tmp/$1_file.gz"
file=$(basename ${remotefilepath})
echo $file
localfilepath="/Users/`whoami`/Downloads/$file"


if [ "$2" = "-rsync" ]; then
  echo "download file from release to local"
  ssh_cmd "mkdir -p $remote_tmp"
  ssh_cmd "docker exec $CONTAINER_NAME pg_dump -U jarvis -d $DATABASE_NAME | gzip -c > $remotefilepath"
  echo "rsync -e ssh jingr@release.s.gigacover.com:$remotefilepath $localfilepath"
  rsync -e ssh jingr@release.s.gigacover.com:$remotefilepath "$localfilepath"
  # unzip first
  echo "gzip -df $localfilepath"
  gzip -df "$localfilepath"
fi

# remove .gz in file
f="${file/.gz/}"
echo "$f from $file"

# restore to db
# remember create database "root" and role "gc_writable" "jarvis" first
#docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE DATABASE root;"
#docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE ROLE gc_writable;"
#docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE ROLE jarvis;"
#docker exec -it lumber_c psql -U postgres -c "CREATE DATABASE root;"
#docker exec -it lumber_c psql -U postgres -c "CREATE ROLE jarvis;"
echo "DROP DATABASE $DATABASE_NAME;"
docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "DROP DATABASE $DATABASE_NAME;"

echo "CREATE DATABASE $DATABASE_NAME;"
docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE DATABASE $DATABASE_NAME;"

echo "cat ~/Downloads/$f | docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d $DATABASE_NAME"
cat ~/Downloads/$f | docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d $DATABASE_NAME

print_exe_time "${STARTTIME}"
