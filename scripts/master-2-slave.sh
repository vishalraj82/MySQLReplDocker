#! /bin/bash

set -x

# Add a wait for containers to be ready
sleep 5

# Install the mysql client
apt-get -qq update
apt-get -qq install mysql-client -y --no-install-recommends

# Create a user on master node
MYSQL_QUERY="CREATE USER '$SLAVE_REPL_USER'@'$SLAVE_HOST_IP' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOST_IP" -e "$MYSQL_QUERY"

# Grant replication permission to the user on master node
MYSQL_QUERY="GRANT REPLICATION SLAVE ON *.* TO \"$SLAVE_REPL_USER\"@\"$SLAVE_HOST_IP\" IDENTIFIED BY \"$SLAVE_REPL_PASSWORD\";"
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOST_IP" -AN -e "$MYSQL_QUERY"

# Reload privileges for replication to take effect
MYSQL_QUERY="FLUSH PRIVILEGES;"
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOST_IP" -e "$MYSQL_QUERY"

# See the privileges for replication user
MYSQL_QUERY="FLUSH TABLES WITH READ LOCK;"
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOST_IP" -e "$MYSQL_QUERY"

# Dump the replication database to be uploaded in slave node
mysqldump --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOST_IP" --all-database --add-drop-database --add-drop-table > /tmp/master.dump.sql

ls -l /tmp/*.sql

# Unlock the tables on master
MYSQL_QUERY="UNLOCK TABLES;"
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOST_IP" -e "$MYSQL_QUERY;"
    
# Import replication database in slave
mysql --user="$SLAVE_ROOT_USER" --password= "$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOST_IP" < /tmp/master.dump.sql

REPL_LOG_FILE=$(eval "mysql --user=$MASTER_ROOT_USER --password=$MASTER_ROOT_PASSWORD --host=$MASTER_HOST_IP -e 'SHOW MASTER STATUS\G' | grep File | sed -n -e 's/^.*: //p'")
REPL_LOG_POSITION=$(eval "mysql --user=$MASTER_ROOT_USER --password=$MASTER_ROOT_PASSWORD --host=$MASTER_HOST_IP -e 'SHOW MASTER STATUS\G' | grep Position | sed -n -e 's/^.*: //p'")

MYSQL_QUERY="CHANGE MASTER TO MASTER_HOST = '$MASTER_HOST_IP', MASTER_USER = '$SLAVE_REPL_USER', MASTER_PASSWORD = '$SLAVE_REPL_PASSWORD', MASTER_LOG_FILE = '$REPL_LOG_FILE', MASTER_LOG_POS = $REPL_LOG_POSITION;"

mysql --user="$SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOST_IP" -e "$MYSQL_QUERY"

# Start the slave for replication
MYSQL_QUERY="START SLAVE;"
mysql --user="$SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOST_IP" -e "$MYSQL_QUERY"

# See the slave status
MYSQL_QUERY="SHOW SLAVE STATUS \G;"
mysql --user="$SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOST_IP" -e "$MYSQL_QUERY"



# IMPORTANT
#
# Uncomment the lines below to check if the replication setup has been setup correctly.
# This would create a new database `demo` and and two new tables `users1` and `users2`
# in demo with 1k an 50k corresponding entries

# Extract the dump zip
# tar xvzf /opt/scripts/users.sql.tgz -C /opt/scripts/

# Dump sample data in master
# mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOST_IP" < /opt/scripts/users1.sql
# mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOST_IP" < /opt/scripts/users2.sql

# Wait 5 seconds before checking the slave status again
# sleep 5;

# See the slave status after dump
# MYSQL_QUERY="SHOW SLAVE STATUS \G;"
# mysql --user="$SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOST_IP" -e "$MYSQL_QUERY"
