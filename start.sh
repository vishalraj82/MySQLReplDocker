#! /bin/bash

source check_params.sh

if [ $file_found -eq 1 ]
    echo Using docker configuration file : $file
    echo
    docker-compose up -f $file  mysql_master mysql_slave replication
fi
