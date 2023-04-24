# usage
# run on release to have backup file: docker exec phoenix_db_c pg_dump -Ujarvis -d phoenix | gzip -c > /tmp/hoa/phoenix_20230202_1156.gz
#./script/tool_script/rsync_backup_file_from_release.sh /tmp/don/ phoenix_file.gz

STARTTIME=$(date +%s)
function print_exe_time() {
    STARTTIME=${1}
    ENDTIME=$(date +%s)
    EXE_TIME=$((${ENDTIME} - ${STARTTIME}))
    printf "
It takes ${GR}%s${EC} seconds to complete this script...\n" " ${EXE_TIME}"
}
# download file from release to local
# if param is phoenix, then use phoenix_db_c
# if param is lens, then use lens_c
# if param is swift, then use swift_c
# if param is don, then use don_c
if [ "$1" = "phoenix" ]; then
  POSTGRES_USER='postgres'
  CONTAINER_NAME="phoenix_db_c"
  filepath=/tmp/don/phoenix_file.gz
elif [ "$1" = "lens" ]; then
  POSTGRES_USER='root'
  CONTAINER_NAME="lens_c"
  filepath=/tmp/don/lens_file.gz
elif [ "$1" = "swift" ]; then
  POSTGRES_USER='root'
  CONTAINER_NAME="swift_c"
  filepath=/tmp/don/swift_file.gz
elif [ "$1" = "don" ]; then
  filepath=/tmp/don/phoenix_file.gz
fi

file=$(basename ${filepath})
echo $file

if [ "$2" = "-rsync" ]; then
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
if [ "$1" = "phoenix" ]; then
  echo "DROP DATABASE phoenix;"
  docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "DROP DATABASE phoenix;"

  echo "CREATE DATABASE phoenix;"
  docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE DATABASE phoenix;"

  echo "cat ~/Downloads/$f | docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d phoenix"
  cat ~/Downloads/$f | docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d phoenix
elif [ "$1" = "lens" ]; then
  echo "DROP DATABASE lens_m;"
  docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "DROP DATABASE lens_m;"

  echo "CREATE DATABASE lens_m;"
  docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE DATABASE lens_m;"

  echo "cat ~/Downloads/$f | docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d lens_m"
  cat ~/Downloads/$f | docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d lens_m
elif [ "$1" = "swift" ]; then
  echo "DROP DATABASE swift_m;"
  docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "DROP DATABASE swift_m;"

  echo "CREATE DATABASE swift_m;"
  docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE DATABASE swift_m;"

  echo "cat ~/Downloads/$f | docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d swift_m"
  cat ~/Downloads/$f | docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d swift_m
elif [ "$1" = "don" ]; then
  echo "Do nothing"
fi

print_exe_time "${STARTTIME}"
