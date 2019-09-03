#! /bin/bash

source check_params.sh

check_docker_config

echo "Using configuration file $file"
echo
docker-compose -f $file down

if [ "$2" == "clean" ]
then
    for datadir in master1 master1 slave1 slave2
    do
        sudo rm -rf data/$datadir/*
    done
fi
