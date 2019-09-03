#! /bin/bash

set -x

#######################################################################################################################
# Install the mysql client to connect to mysql nodes
#######################################################################################################################
apt-get -qq update
apt-get -qq install mysql-client -y --no-install-recommends


#######################################################################################################################
# Import common functions
#######################################################################################################################
BASEDIR=$(dirname "$0")
source $BASEDIR/common-functions.sh


#######################################################################################################################
# Setup replication from master1 to master2
#######################################################################################################################
setup_master_2_slave_replication $MASTER_1_HOST_IP $MASTER_1_ROOT_USER $MASTER_1_ROOT_PASSWORD $MASTER_2_HOST_IP $MASTER_2_ROOT_USER $MASTER_2_ROOT_PASSWORD $REPL_USER $REPL_PASSWORD

# Add some gap intentionally
sleep 5

#######################################################################################################################
# Setup replication from master2 to master1
#######################################################################################################################
setup_master_2_slave_replication $MASTER_2_HOST_IP $MASTER_2_ROOT_USER $MASTER_2_ROOT_PASSWORD $MASTER_1_HOST_IP $MASTER_1_ROOT_USER $MASTER_1_ROOT_PASSWORD $REPL_USER $REPL_PASSWORD