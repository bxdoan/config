#!/bin/bash
PWD=`cd $(dirname "$BASH_SOURCE") && pwd`; CODE=`cd $PWD/.. && pwd`
usage_hint="
    ./bin/setup-test-parallel.sh <your_id>
    example:
    ./bin/setup-test-parallel.sh dn
"

set -e  # DO NOT turn set -e on cause it will make xdist-run exit exit_code=1 ie failed if any rerun occurred even when that results as all-test-passed ref. https://stackoverflow.com/a/11231970/248616
if [[ -z $1 ]]; then
    echo "
    Your id should be provided.
    EX:     ./bin/setup-test-parallel.sh <your_id>
            ./bin/setup-test-parallel.sh dn

    NOTE:
    EX:     ./bin/setup-test-parallel.sh dn 8
"
    exit 1;
fi

post_fix=$1
pg="gc_postgres_${post_fix}"

if [[ $2 == '8' ]]; then
    number_db=8
else
    number_db=4
fi

# find existing gc_postgres
docker ps | grep ${pg} > /dev/null
if [[ $? -eq 1 ]]; then
    docker run --name ${pg} -d mdillon/postgis
fi
PSQL="docker exec ${pg} psql -Upostgres" ./db/create_db.sh ${number_db}
PSQL="docker exec ${pg} psql -Upostgres" ./bin/modify-connections-postgresqlconf.sh 800
docker restart ${pg}


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
