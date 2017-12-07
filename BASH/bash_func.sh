#!/bin/bash

### Usage:
###   string_join <delimiter> <arg1> <arg2> ...
### Ex:
###   $ string_join : a b c
###       a:b:c
string_join () {
    local delim=$1      # delimiter for joining
    shift
    local backupIFS=$IFS   # save IFS, the field separator
    IFS=$delim
    local result="$*"
    IFS=$oldIFS   # restore IFS
    echo $result
}

### Usage:
###   add_PATH <arg1> <arg2> ...
### Ex:
###   $ add_PATH /a /b /c
###       ...:/a:/b:/c
add_PATH () {
    local result=$(string_join : "$@")
    PATH=$PATH:$result
}

### Usage:
###   change_PS1
# helper functions for Bash - easier coloring than using escape sequences
function Color() {
  echo "\[$(tput setaf $1)\]"
}
function ResetColor() {
  echo "\[$(tput sgr0)\]"
}

function GitBranch() {
    git symbolic-ref --short HEAD &> /dev/null
    if [ $? -ne 0 ]; then
        git symbolic-ref --short HEAD
    fi
}


LastExitStatus() {
    local last_status=$?
    local reset=$(ResetColor)

    local failure="X"
    local success="O"

    if [[ "$last_status" != "0" ]]; then
        last_status="$(Color 5)$failure$reset"
    else
        last_status="$(Color 2)$success$reset"
    fi
    echo "$last_status"
}

change_PS1 () {
    PROMPT_COMMAND='exitstatus=$(LastExitStatus);\
background=$(Color 18);\
historyId=$(Color 255);\
user=$(Color 3);\
at=$(Color 255);\
host=$(Color 3);\
time=$(Color 255);\
dir=$(Color 208);\
branch=$(Color 40);\
bold=$(tput bold);\
reset=$(ResetColor);\
PS1="\n$background$historyId{\!} $user\u$at@$host\h $time\A $dir${PWD} $branch$bold$(GitBranch)$reset\n${exitstatus} "'
}

