#! /bin/bash

set -x

source check_params.sh

check_docker_config

echo "Using configuration file $file"
echo
docker-compose -f $file down

if [ "$2" == "clean" ]
then
    for node in "master" "slave"
    do
        for num in 1 2
        do
            sudo rm -rf data/$node$num/*
        done
    done
fi
