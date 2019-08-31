#! /bin/bash

source check_params.sh

if [ $file_found -eq 0 ]
then
    check_docker_config
fi

if [ $file_found -eq 1 ]
    file="$docker_folder/$file"
    echo Using docker configuration file : $file
    echo
    docker-compose up -f $file  mysql_master mysql_slave replication
fi
