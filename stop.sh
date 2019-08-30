#! /bin/bash

source check_params.sh

echo $file

exit 0

docker-compose -f $file down

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
