This is a sample work to learn about docker, containers, running MySQL in docker and setting up MySQL
replication using docker containers.

Here is the directory structure and its explanation

    MySQLReplDocker
        |
        +--- conf/
        |       |
        |       +--- master1.cnf
        |       +--- master2.cnf
        |       +--- slave1.cnf
        |       +--- slave2.cnf
        |
        +--- data/
        |       |
        |       +--- master1/
        |       +--- master2/
        |       +--- slave1/
        |       +--- slave2/
        |
        +--- docker/
        |       |
        |       +--- master-2-slave.yml
        |       +--- master-2-master.yml
        |       +--- slave-2-master-2-master-2-slave.yml
        |
        +--- scripts/
        |       |
        |       +--- common-functions.sh
        |       +--- master-2-slave.sh
        |       +--- master-2-master.sh
        |       +--- slave-2-master-2-master-2-slave.sh
        |
        +--- start.sh
        +--- stop.sh
        +--- check_params.sh


The folder "conf" contains the MySQL configuration for master and slave nodes.

The folder "data" contains folders to hold data for master and slave nodes.

The folder "docker" contains the docker container configuation files

The folder "scripts" contains bash script which does the real job of setup of replication between the nodes
