#! /bin/bash

source check_params.sh

if [ $file_found -eq 0 ]
then
    check_docker_config
fi

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
