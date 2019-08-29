#! /bin/bash

#set -x

# Add a wait for containers to be ready
#sleep 5

# Install the mysql client
apt-get -qq update
apt-get -qq install mysql-client -y --no-install-recommends

# # Create a user on master node
# mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" \
#     -e "CREATE USER '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"

# Grant replication permission to the user on master node
echo "Granting permssion on master for replication"
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" \
    -e "GRANT REPLICATION SLAVE ON *.* TO '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"

# Reload privileges for replication to take effect
echo "Flushing privileges for replication permission to take effect"
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" \
    -e "FLUSH PRIVILEGES;"

# See the privileges for replication user
echo "Flushing tables with read lock"
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" \
    -e "FLUSH TABLES WITH READ LOCK;" 

# Dump the replication database to be uploaded in slave node
echo "Dumping all database from master"
mysqldump --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" \
    --all-database \
    --add-drop-database \
    --add-drop-table > /tmp/master.dump.sql

ls -l /tmp/*.sql

# Unlock the tables on master
echo "Flushing tables with read lock"
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" \
    -e "UNLOCK TABLES;"
    
# # Import replication database in slave
echo "Importing dump from master to slave"
mysql --user="$SLAVE_ROOT_USER" --password= "$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOSTNAME" < cat /tmp/master.dump.sql

REPL_LOG_FILE=$(eval "mysql --user=$MASTER_ROOT_USER --password=$MASTER_ROOT_PASSWORD --host=$MASTER_HOSTNAME -e 'SHOW MASTER STATUS\G' | grep File | sed -n -e 's/^.*: //p'")
REPL_LOG_POSITION=$(eval "mysql --user=$MASTER_ROOT_USER --password=$MASTER_ROOT_PASSWORD --host=$MASTER_HOSTNAME -e 'SHOW MASTER STATUS\G' | grep Position | sed -n -e 's/^.*: //p'")

QUERY="CHANGE MASTER TO MASTER_HOST = '$MASTER_HOSTNAME', MASTER_USER = '$SLAVE_REPL_USER', MASTER_PASSWORD = '$SLAVE_REPL_PASSWORD', MASTER_LOG_FILE = '$REPL_LOG_FILE', MASTER_LOG_POS = $REPL_LOG_POSITION;"

# echo "Switching master on slave machine"
echo *************************************************************************************
echo $QUERY
echo *************************************************************************************
mysql --user="$SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOSTNAME" \
    -e $QUERY

# # Start the slave for replication
# echo "Starting slave"
# mysql --user="$SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOSTNAME" \
#     -e "START SLAVE;"

# # See the slave status
# echo "Checking slave status"
# mysql --user="$SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOSTNAME" \
#     -e "SHOW SLAVE STATUS \G;"

# # Dump sample data in master
# mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" < cat /opt/scripts/Demo-1K-Rows.sql

# # See the slave status after dump
# mysql --user="SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOSTNAME" \
#     -e "SHOW SLAVE STATUS \G;"