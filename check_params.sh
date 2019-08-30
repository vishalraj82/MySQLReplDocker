#! /bin/bash

file=$1
file_found=0

if [ "$1" == "ms" ]
then
    file="master-2-slave.yml"
    file_found=1
elif [ "$1" == "mm" ]
then
    file="master-2-master.yml"
    file_found=1
elif [ "$1" == "smms" ]
then
    file="slave-2-master-2-master-2-slave.yml"
    file_found=1
fi


if [ $file_found -eq 0 ]
then
    cfiles=("master-2-slave.yml" "master-2-master.yml" "slave-2-master-2-master-2-slave.yml")
    for cfile in ${cfiles[@]}
    do
        if [ "$cfile" == "$1" ]
        then
            file_found=1
            break;
        fi
    done
fi

echo 

if [ $file_found -eq 0 ]
then
    echo "Invalid configuration file specified"
    echo 
    echo "Usage: bash start.sh ms|mm|smms"
    echo
fi
