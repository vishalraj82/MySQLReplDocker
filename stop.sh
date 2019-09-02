#! /bin/bash

source check_params.sh

check_docker_config

echo "Using configuration file $file"
#docker-compose -f $file down

if [ "$2" == "clean" ]
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
