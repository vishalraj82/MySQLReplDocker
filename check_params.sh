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
        echo "Usage: bash start.sh <short-option|long-option>"
        echo
        echo "Short options: ms              | mm               | smms"
        echo "Long options : master-to-slave | master-to-master | slave-to-master-to-slave"
        echo
        exit 0
    fi
}

function check_shortcut() {
    case $file in
        "ms"|"masterslave"|"master-slave"|"master2slave"|"master-2-slave")
            file="master-2-slave.yml"
            file_found=1
            ;;
        "mm"|"mastermaster"|"master-master"|"master2master"|"master-2-master")
            file="master-2-master.yml"
            file_found=1
            ;;
        "smms"|"slavemastermasterslave"|"slave-master-master-slave"|"slave2master2master2slave"|"slave-2-master-2-master-2-slave")
            file="slave-2-master-2-master-2-slave.yml"
            file_found=1
            ;;
    esac

}

function check_docker_config() {
    check_shortcut

    if [ $file_found -eq 1 ]
    then
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
    else
        show_usage
    fi
}
