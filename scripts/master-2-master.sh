#! /bin/bash

set -x

# Add a wait for containers to be ready
sleep 5

# Install the mysql client
apt-get -qq update
apt-get -qq install mysql-client -y --no-install-recommends

#######################################################################################################################
# Setup replication from master1 to master2
#######################################################################################################################

# Create a user on master1 node
MYSQL_QUERY="CREATE USER '$SLAVE_REPL_USER'@'$MASTER_2_HOST_IP' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"
mysql --user="$MASTER_1_ROOT_USER" --password="$MASTER_1_ROOT_PASSWORD" --host="$MASTER_1_HOST_IP" -e "$MYSQL_QUERY"

# Grant replication permission to the user on master1 node
MYSQL_QUERY="GRANT REPLICATION SLAVE ON *.* TO \"$SLAVE_REPL_USER\"@\"$MASTER_2_HOST_IP\";"
mysql --user="$MASTER_1_ROOT_USER" --password="$MASTER_1_ROOT_PASSWORD" --host="$MASTER_1_HOST_IP" -AN -e "$MYSQL_QUERY"

# Reload privileges for replication to take effect
MYSQL_QUERY="FLUSH PRIVILEGES;"
mysql --user="$MASTER_1_ROOT_USER" --password="$MASTER_1_ROOT_PASSWORD" --host="$MASTER_1_HOST_IP" -e "$MYSQL_QUERY"

# See the privileges for replication user
MYSQL_QUERY="FLUSH TABLES WITH READ LOCK;"
mysql --user="$MASTER_1_ROOT_USER" --password="$MASTER_1_ROOT_PASSWORD" --host="$MASTER_1_HOST_IP" -e "$MYSQL_QUERY"

REPL_LOG_FILE=$(eval "mysql --user=$MASTER_1_ROOT_USER --password=$MASTER_1_ROOT_PASSWORD --host=$MASTER_1_HOST_IP -e 'SHOW MASTER STATUS\G' | grep File | sed -n -e 's/^.*: //p'")
REPL_LOG_POSITION=$(eval "mysql --user=$MASTER_1_ROOT_USER --password=$MASTER_1_ROOT_PASSWORD --host=$MASTER_1_HOST_IP -e 'SHOW MASTER STATUS\G' | grep Position | sed -n -e 's/^.*: //p'")

# Set the replication on slave node
MYSQL_QUERY="CHANGE MASTER TO MASTER_HOST = '$MASTER_1_HOST_IP', MASTER_USER = '$SLAVE_REPL_USER', MASTER_PASSWORD = '$SLAVE_REPL_PASSWORD', MASTER_LOG_FILE = '$REPL_LOG_FILE', MASTER_LOG_POS = $REPL_LOG_POSITION;"
mysql --user="$MASTER_2_ROOT_USER" --password="$MASTER_2_ROOT_PASSWORD" --host="$MASTER_2_HOST_IP" -e "$MYSQL_QUERY"

# Start the master2 for replication
MYSQL_QUERY="START SLAVE;"
mysql --user="$MASTER_2_ROOT_USER" --password="$MASTER_2_ROOT_PASSWORD" --host="$MASTER_2_HOST_IP" -e "$MYSQL_QUERY"

# See the master2 status
MYSQL_QUERY="SHOW SLAVE STATUS \G;"
mysql --user="$MASTER_2_ROOT_USER" --password="$MASTER_2_ROOT_PASSWORD" --host="$MASTER_2_HOST_IP" -e "$MYSQL_QUERY"




#######################################################################################################################
# Setup replication from master2 to master1
#######################################################################################################################

# Create a user on master1 node
MYSQL_QUERY="CREATE USER '$SLAVE_REPL_USER'@'$MASTER_1_HOST_IP' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"
mysql --user="$MASTER_2_ROOT_USER" --password="$MASTER_2_ROOT_PASSWORD" --host="$MASTER_2_HOST_IP" -e "$MYSQL_QUERY"

# Grant replication permission to the user on master1 node
MYSQL_QUERY="GRANT REPLICATION SLAVE ON *.* TO \"$SLAVE_REPL_USER\"@\"$MASTER_1_HOST_IP\";" #IDENTIFIED BY \"$SLAVE_REPL_PASSWORD\";"
mysql --user="$MASTER_2_ROOT_USER" --password="$MASTER_2_ROOT_PASSWORD" --host="$MASTER_2_HOST_IP" -AN -e "$MYSQL_QUERY"

# Reload privileges for replication to take effect
MYSQL_QUERY="FLUSH PRIVILEGES;"
mysql --user="$MASTER_2_ROOT_USER" --password="$MASTER_2_ROOT_PASSWORD" --host="$MASTER_2_HOST_IP" -e "$MYSQL_QUERY"

# See the privileges for replication user
MYSQL_QUERY="FLUSH TABLES WITH READ LOCK;"
mysql --user="$MASTER_2_ROOT_USER" --password="$MASTER_2_ROOT_PASSWORD" --host="$MASTER_2_HOST_IP" -e "$MYSQL_QUERY"

REPL_LOG_FILE=$(eval "mysql --user=$MASTER_2_ROOT_USER --password=$MASTER_2_ROOT_PASSWORD --host=$MASTER_2_HOST_IP -e 'SHOW MASTER STATUS\G' | grep File | sed -n -e 's/^.*: //p'")
REPL_LOG_POSITION=$(eval "mysql --user=$MASTER_2_ROOT_USER --password=$MASTER_2_ROOT_PASSWORD --host=$MASTER_2_HOST_IP -e 'SHOW MASTER STATUS\G' | grep Position | sed -n -e 's/^.*: //p'")

# Set the replication on slave node
MYSQL_QUERY="CHANGE MASTER TO MASTER_HOST = '$MASTER_2_HOST_IP', MASTER_USER = '$SLAVE_REPL_USER', MASTER_PASSWORD = '$SLAVE_REPL_PASSWORD', MASTER_LOG_FILE = '$REPL_LOG_FILE', MASTER_LOG_POS = $REPL_LOG_POSITION;"
mysql --user="$MASTER_1_ROOT_USER" --password="$MASTER_1_ROOT_PASSWORD" --host="$MASTER_1_HOST_IP" -e "$MYSQL_QUERY"

# Start the master2 for replication
MYSQL_QUERY="START SLAVE;"
mysql --user="$MASTER_1_ROOT_USER" --password="$MASTER_1_ROOT_PASSWORD" --host="$MASTER_1_HOST_IP" -e "$MYSQL_QUERY"

# See the master2 status
MYSQL_QUERY="SHOW SLAVE STATUS \G;"
mysql --user="$MASTER_1_ROOT_USER" --password="$MASTER_1_ROOT_PASSWORD" --host="$MASTER_1_HOST_IP" -e "$MYSQL_QUERY"
