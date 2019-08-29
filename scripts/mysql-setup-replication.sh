#! /bin/bash

set -x

# Add a wait for containers to be ready
sleep 5

# Install the mysql client
apt-get -qq update
apt-get install mysql-client -y --no-install-recommends

Create a user on master node
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" \
    -e "CREATE USER '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"

# Grant replication permission to the user on master node
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" \
    -e "GRANT REPLICATION SLAVE ON *.* TO '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"

# Reload privileges for replication to take effect
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" \
    -e "FLUSH PRIVILEGES;"

# See the privileges for replication user
mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" \
    -e "SHOW GRANTS FOR '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME';"


# Dump the replication database to be uploaded in slave node
mysqldump --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" \
    --add-drop-database \
    --add-drop-table \
    "$MASTER_REPL_DB" > "$MASTER_REPL_DB.sql"

cat "$MASTER_REPL_DB.sql"

    
# Dump replication data in master
# mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME"  < "$MASTER_REPL_DB.sql"

# # Import replication database in slave
# mysql --user="$SLAVE_ROOT_USER" --password= "$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOSTNAME" < cat "$MASTER_REPL_DB.sql"

# REPL_LOG_FILE=$(eval "mysql --user=$MASTER_ROOT_USER --password=$MASTER_ROOT_PASSWORD --host=$MASTER_HOSTNAME -e 'SHOW MASTER STATUS\G' | grep File | sed -n -e 's/^.*: //p'")
# REPL_LOG_POSITION=$(eval "mysql --user=$MASTER_ROOT_USER --password=$MASTER_ROOT_PASSWORD --host=$MASTER_HOSTNAME -e 'SHOW MASTER STATUS\G' | grep Position | sed -n -e 's/^.*: //p'")

# QUERY="CHANGE MASTER TO MASTER_HOST = '$MASTER_HOSTNAME', MASTER_USER = '$SLAVE_REPL_USER', MASTER_PASSWORD = '$SLAVE_REPL_PASSWORD', MASTER_LOG_FILE = '$REPL_LOG_FILE', MASTER_LOG_POS = $REPL_LOG_POSITION;"

# mysql --user="SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOSTNAME" \
#     -e $QUERY

# # Start the slave for replication
# mysql --user="SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOSTNAME" \
#     -e "START SLAVE;"

# # See the slave status
# mysql --user="SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOSTNAME" \
#     -e "SHOW SLAVE STATUS \G;"

# # Dump sample data in master
# mysql --user="$MASTER_ROOT_USER" --password="$MASTER_ROOT_PASSWORD" --host="$MASTER_HOSTNAME" < cat /opt/scripts/Demo-1K-Rows.sql

# # See the slave status after dump
# mysql --user="SLAVE_ROOT_USER" --password="$SLAVE_ROOT_PASSWORD" --host="$SLAVE_HOSTNAME" \
#     -e "SHOW SLAVE STATUS \G;"