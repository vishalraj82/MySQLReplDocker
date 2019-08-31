#! /bin/bash

BASEDIR=$(dirname "$0")

file=$1 file_found=0
usage_shown=0
docker_folder="$BASEDIR/docker"

function show_usage() {
    if [ $file_found -eq 0 ]
    then
        echo "Invalid configuration file specified"
        echo 
        echo "Usage: bash start.sh ms|mm|smms"
        echo
    fi
}

function check_shortcut() {
    if [ "$file" == "ms" ]
    then
        file="master-2-slave.yml"
    elif [ "$file" == "mm" ]
    then
        file="master-2-master.yml"
    elif [ "$" == "smms" ]
    then
        file="slave-2-master-2-master-2-slave.yml"
    fi
}

function check_docker_config() {
    check_shortcut

    cfiles=("master-2-slave.yml" "master-2-master.yml" "slave-2-master-2-master-2-slave.yml")
    for cfile in ${cfiles[@]}
    do
        if [ "$cfile" == "$file" ] && [ -f "$docker_folder/$cfile" ]
        then
            file=$docker_folder/$cfile
            file_found=1
            break;
        fi
    done

    show_usage
}
