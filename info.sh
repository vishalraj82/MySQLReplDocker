#! /bin/bash

set -x

source check_params.sh

check_docker_config

docker-compose -f $file ps
