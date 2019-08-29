#! /bin/bash

set -x

# trap ctrl-c and call ctrl_c()
#trap ctrl_c INT

#function ctrl_c() {
#    docker-compose down --remove-orphans
#    docker-compose ps
#    #docker volume ls | awk '{ print $2 }' | grep "^[a\-z0\-9]\+" | xargs docker volume rm
#}

arg1=$1
arg2=$1

if [ "$arg1" == "clean" || "$arg1" == "cleanup"]
then
    arg2=$2
fi

if [ "${arg1:0:5}" == "clean" ]
then
    for par in "master" "slave"
    do
        for chi in "var/lib/" "var/log" "var/run"
        do
            chd=$chi/mysql
            sudo rm -rf $par/$chd/* $par/$chd/* $par/$chd/*
        done
    done
fi

if [ "$arg1" == "cleanup" ]
then
    exit 0;
fi

if [ "$arg2" == "setup" ]
then
    docker-compose up mysql_repliation_setup
    exit 0;
fi

docker-compose up --force-recreate