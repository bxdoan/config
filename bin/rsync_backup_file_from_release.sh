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
# download file from release to local
don_dir=/tmp/don

POSTGRES_USER='root'
CONTAINER_NAME="$1_c"
DATABASE_NAME="$1_m"
if [ "$1" = "phoenix" ]; then
  POSTGRES_USER='postgres'
  CONTAINER_NAME="phoenix_db_c"
  DATABASE_NAME='phoenix'
fi

filepath="$don_dir/$1_file.gz"
file=$(basename ${filepath})
echo $file

if [ "$2" = "-rsync" ]; then
  ssh jingr@release.s.gigacover.com "mkdir -p $don_dir"

  cmd_dump="docker exec $CONTAINER_NAME pg_dump -U jarvis -d $DATABASE_NAME | gzip -c > $filepath"
  echo "ssh jingr@release.s.gigacover.com $cmd_dump"
  ssh jingr@release.s.gigacover.com $cmd_dump

  echo "rsync -e ssh jingr@release.s.gigacover.com:$filepath ~/Downloads/$file"
  rsync -e ssh jingr@release.s.gigacover.com:$filepath ~/Downloads/$file
fi

# remove .gz in file
f="${file/.gz/}"
echo "$f from $file"

# unzip first
echo "gzip -df ~/Downloads/$file"
gzip -df ~/Downloads/$file

# restore to db

# remember create database "root" and role "gc_writable" "jarvis" first
#docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE DATABASE root;"
#docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE ROLE gc_writable;"
#docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE ROLE jarvis;"
echo "DROP DATABASE $DATABASE_NAME;"
docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "DROP DATABASE $DATABASE_NAME;"

echo "CREATE DATABASE $DATABASE_NAME;"
docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE DATABASE $DATABASE_NAME;"

echo "cat ~/Downloads/$f | docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d $DATABASE_NAME"
cat ~/Downloads/$f | docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d $DATABASE_NAME

print_exe_time "${STARTTIME}"
