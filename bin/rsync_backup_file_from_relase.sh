# usage
# run on release to have backup file: docker exec phoenix_db_c pg_dump -Ujarvis -d phoenix | gzip -c > /tmp/hoa/phoenix_20230202_1156.gz
#./script/tool_script/rsync_backup_file_from_relase.sh /tmp/hoa/ phoenix_20230121_0836.gz

# download file from relase to local
POSTGRES_USER='postgres'
CONTAINER_NAME="phoenix_db_c"
filepath=/tmp/don/phoenix_file.gz
file=$(basename ${filepath})
echo $file
echo  "rsync -e ssh jingr@release.s.gigacover.com:$filepath ~/Downloads/$file"
rsync -e ssh jingr@release.s.gigacover.com:$filepath ~/Downloads/$file

# remove .gz in file
f="${file/.gz/}"
echo "$f from $file"

# unzip first
gzip -d ~/Downloads/$file

# restore to db
docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE ROLE gc_writable;"
docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE ROLE jarvis;"
docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "DROP DATABASE phoenix;"
docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE DATABASE phoenix;"
cat ~/Downloads/$f | docker exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -dphoenix