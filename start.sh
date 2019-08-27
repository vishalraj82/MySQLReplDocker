#! /bin/bash

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
    docker-compose down --remove-orphans
}

if [ "$1" == "clean" ]
then
    for dir in "master" "slave"
    do
        sudo rm -rf $dir/var/lib/mysql/* $dir/var/log/mysql/*
    done
fi

docker-compose up --force-recreate
