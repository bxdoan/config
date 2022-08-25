#!/bin/bash
PWD=`cd $(dirname "$BASH_SOURCE") && pwd`; CODE=`cd $PWD/.. && pwd`
STARTTIME=$(date +%s)

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

DIR_TEST=$1
if [[ -z $DIR_TEST ]]; then DIR_TEST=''; fi

XDIST_WORKER_NUM=$2
if [[ -z $XDIST_WORKER_NUM ]]; then XDIST_WORKER_NUM=6; fi

cd $CODE
    if [[ $skip_pipenv_sync == 0 ]]; then
        pipenv sync
    fi
    pipenv run pytest -p no:warnings --tb=short    -n${XDIST_WORKER_NUM}   "$DIR_TEST"
    #                 #no warning  #traceback short  #no of worker to run
echo "Done running xdist mode - status_code=$?"

print_exe_time ${STARTTIME}

usage_hint="
    PSQL='docker exec gc_postgres psql -Upostgres' ./db/drop_xdist_db.sh
    PSQL='docker exec gc_postgres psql -Upostgres' ./db/create_db.sh
    PSQL='docker exec gc_postgres psql -Upostgres' ./bin/modify-connections-postgresqlconf.sh 500
    docker restart gc_postgres
    docker exec gc_postgres psql -Upostgres -c 'show max_connections' -t

    ./tmp/run-test-parallel.sh
    ./tmp/run-test-parallel.sh  tests/api          8
    #                           #DIR_TEST    #number of worker
"
