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

# number of CPU cores for ubuntu ref. https://stackoverflow.com/a/17089001/248616
#                         macos  ref. https://github.com/memkind/memkind/issues/33#issuecomment-316615308
if [[ "$OSTYPE" = "darwin"* ]]; then cpu_cores=`sysctl -n hw.physicalcpu`; else cpu_cores=`nproc --all`; fi

if [[ $cpu_cores -lt 2 ]]; then
    echo; echo "Require CPU to have >=2 cores in xdist parallel mode - this machine has $cpu_cores";
    exit 1;
else
    echo; echo "Running pytest-xdist with $cpu_cores cores";
fi

pytest_run_log=`mktemp`
echo "Log file written to $pytest_run_log"; echo

DIR_TEST=$1
if [[ -z $DIR_TEST ]]; then DIR_TEST=''; fi

XDIST_WORKER_NUM=$2
if [[ -z $XDIST_WORKER_NUM ]]; then XDIST_WORKER_NUM=4; fi

cd $CODE
    pipenv run pytest -p no:warnings --tb=short    -n${XDIST_WORKER_NUM}  $DIR_TEST --reruns 1  --max-worker-restart=0  ${@:3} 2>&1 | tee $pytest_run_log
    #                 #no warning  #traceback short  #no of worker to run
echo "Done running xdist mode - status_code=$?"

has_failed_xdist_test=`grep -c  -E '=+.+failed|=+.+error'  $pytest_run_log `  # know if parallel test failed ref. https://github.com/namgivu/pytest-start/commit/a921f9bf2d66519604e5b6846afedfd17198efc1
if [[ "$has_failed_xdist_test" == "0" ]]; then
    print_exe_time ${STARTTIME}
    exit 0
else
    pipenv run pytest  -p no:warnings  --tb=short        --lf                 2>&1 | tee $pytest_run_log
    #                  #no warning     #traceback short  #reruns last failed  #also log to file
    print_exe_time ${STARTTIME}
    has_failed_2nd_run=`grep -c  -E '=+.+failed|=+.+error'  $pytest_run_log `  # know if parallel test failed ref. https://github.com/namgivu/pytest-start/commit/a921f9bf2d66519604e5b6846afedfd17198efc1
    if [[ $has_failed_2nd_run == '0' ]]; then
        exit 0
    else
        echo "All efforts failed"
        exit 1
    fi
fi
