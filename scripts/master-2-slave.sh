#! /bin/bash

set -x

# Add a wait for containers to be ready
sleep 5

# Install the mysql client
apt-get -qq update
apt-get -qq install mysql-client -y --no-install-recommends

function create_slave_replication_user_on_master() {
    MASTER_HOST_IP=$1
    MASTER_ROOT_USER=$2
    MASTER_ROOT_PASSWORD=$3

    SLAVE_HOST_IP=$4
    SLAVE_REPL_USER=$5
    SLAVE_REPL_PASSWORD=$6

    MYSQL_QUERY="CREATE USER '$SLAVE_REPL_USER'@'$SLAVE_HOST_IP' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"
    mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOST_IP" -e "$MYSQL_QUERY"
}


function grant_replication_slave_permission_on_master() {
    MASTER_HOST_IP=$1
    MASTER_ROOT_USER=$2
    MASTER_ROOT_PASSWORD=$3
    SLAVE_REPL_USER=$4
    SLAVE_HOST_IP=$5

    MYSQL_QUERY="GRANT REPLICATION SLAVE ON *.* TO \"$SLAVE_REPL_USER\"@\"$SLAVE_HOST_IP\";"
    mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOST_IP" -AN -e "$MYSQL_QUERY"
}

# Reload privileges for replication to take effect
function flush_privileges_for_replication_to_take_effect() {
    MASTER_HOST_IP=$1
    MASTER_ROOT_USER=$2
    MASTER_ROOT_PASSWORD=$3

    MYSQL_QUERY="FLUSH PRIVILEGES;"
    mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOST_IP" -e "$MYSQL_QUERY"
}

function get_master_replication_file_and_position_and_update_slave () {
    MASTER_HOST_IP=$1
    MASTER_ROOT_USER=$2
    MASTER_ROOT_PASSWORD=$3

    SLAVE_HOST_IP=$4
    SLAVE_ROOT_USER=$5
    SLAVE_ROOT_PASSWORD=$6

    SLAVE_REPL_USER=$7
    SLAVE_REPL_PASSWORD=$8

    REPL_LOG_FILE=$(eval "mysql --user=$MASTER_ROOT_USER --password=$MASTER_ROOT_PASSWORD --host=$MASTER_HOST_IP -e 'SHOW MASTER STATUS\G' | grep File | sed -n -e 's/^.*: //p'")
    REPL_LOG_POSITION=$(eval "mysql --user=$MASTER_ROOT_USER --password=$MASTER_ROOT_PASSWORD --host=$MASTER_HOST_IP -e 'SHOW MASTER STATUS\G' | grep Position | sed -n -e 's/^.*: //p'")

    MYSQL_QUERY="CHANGE MASTER TO MASTER_HOST = '$MASTER_HOST_IP', MASTER_USER = '$SLAVE_REPL_USER', MASTER_PASSWORD = '$SLAVE_REPL_PASSWORD', MASTER_LOG_FILE = '$REPL_LOG_FILE', MASTER_LOG_POS = $REPL_LOG_POSITION;"
    mysql --user="$SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOST_IP" -e "$MYSQL_QUERY"
}

function start_slave () {
    SLAVE_HOST_IP=$1
    SLAVE_ROOT_USER=$2
    SLAVE_ROOT_PASSWORD=$3

    MYSQL_QUERY="START SLAVE;"
    mysql --user="$SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOST_IP" -e "$MYSQL_QUERY"
}

function check_slave_status() {
    SLAVE_HOST_IP=$1
    SLAVE_ROOT_USER=$2
    SLAVE_ROOT_PASSWORD=$3

    MYSQL_QUERY="SHOW SLAVE STATUS \G;"
    mysql --user="$SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOST_IP" -e "$MYSQL_QUERY"
}



#######################################################################################################################
# Setup replication from master1 to slave1
#######################################################################################################################

create_slave_replication_user_on_master $MASTER_1_HOST_IP $MASTER_1_ROOT_USER $MASTER_1_ROOT_PASSWORD $SLAVE_1_HOST_IP $SLAVE_REPL_USER $SLAVE_REPL_PASSWORD
grant_replication_slave_permission_on_master $MASTER_1_HOST_IP $MASTER_1_ROOT_USER $MASTER_1_ROOT_PASSWORD $SLAVE_REPL_USER $SLAVE_1_HOST_IP
flush_privileges_for_replication_to_take_effect $MASTER_1_HOST_IP $MASTER_1_ROOT_USER $MASTER_1_ROOT_PASSWORD
get_replication_file_and_position  $MASTER_1_HOST_IP $MASTER_1_ROOT_USER $MASTER_1_ROOT_PASSWORD
get_master_replication_file_and_position_and_update_slave $MASTER_1_HOST_IP $MASTER_1_ROOT_USER $MASTER_1_ROOT_PASSWORD $SLAVE_1_HOST_IP $SLAVE_1_ROOT_USER $SLAVE_1_ROOT_PASSWORD $SLAVE_REPL_USER $SLAVE_REPL_PASSWORD
start_slave $SLAVE_1_HOST_IP $SLAVE_1_ROOT_USER $SLAVE_1_ROOT_PASSWORD
check_slave_status $SLAVE_1_HOST_IP $SLAVE_1_ROOT_USER $SLAVE_1_ROOT_PASSWORD
