#! /bin/bash

set -x

# Install the mysql client
apt-get update
apt-get install mysql-client -y --no-install-recommends

# Add a wait for containers to be ready
sleep 15

# Create a user on master node
mysql \
    -u "$MASTER_ROOT_USER" \
    -p"$MASTER_ROOT_PASSWORD" \
    -h"$MASTER_HOSTNAME" \
    -AN \
    -e "CREATE USER '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"

# Grant replication permission to the user on master node
mysql \
    -u "$MASTER_ROOT_USER" \
    -p"$MASTER_ROOT_PASSWORD" \
    -h"$MASTER_HOSTNAME" \
    -AN \
    -e "GRANT REPLICATION SLAVE ON *.* TO '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"

# Reload privileges for replication to take effect
mysql \
    -u "$MASTER_ROOT_USER" \
    -p"$MASTER_ROOT_PASSWORD" \
    -h"$MASTER_HOSTNAME" \
    -AN \
    -e "FLUSH PRIVILEGES;"

# See the privileges for replication user
mysql \
    -u "$MASTER_ROOT_USER" \
    -p"$MASTER_ROOT_PASSWORD" \
    -h"$MASTER_HOSTNAME" \
    -AN \
    -e "SHOW GRANTS FOR '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME';"


# Dump the replication database to be uploaded in slave node
mysqldump
    -u "$MASTER_ROOT_USER" \
    -p"$MASTER_ROOT_PASSWORD" \
    -h"$MASTER_HOSTNAME" \
    --add-drop-database \
    "$MASTER_REPL_DB" > "$MASTER_REPL_DB.sql"
    

# Import replication database in slave
mysql \
    -u  "$SLAVE_ROOT_USER" \
    -p "$SLAVE_ROOT_PASSWORD" \
    -h "$SLAVE_HOSTNAME" < "$MASTER_REPL_DB.sql"

REPL_LOG_FILE=$(eval "mysql -u $MASTER_ROOT_USER -p$MASTER_ROOT_PASSWORD -h $MASTER_HOSTNAME -e 'SHOW MASTER STATUS\G' | grep File | sed -n -e 's/^.*: //p'")
REPL_LOG_POSITION=$(eval "mysql -u $MASTER_ROOT_USER -p$MASTER_ROOT_PASSWORD -h $MASTER_HOSTNAME -e 'SHOW MASTER STATUS\G' | grep Position | sed -n -e 's/^.*: //p'")


mysql \
    -u "$MASTER_ROOT_USER" \
    -p"$MASTER_ROOT_PASSWORD" \
    -h"$MASTER_HOSTNAME" \
    -AN \
    -e "CHANGE MASTER TO MASTER_HOST='$MASTER_HOSTNAME',MASTER_USER='$SLAVE_REPL_USER', MASTER_PASSWORD='$SLAVE_REPL_PASSWORD', MASTER_LOG_FILE='$REPL_LOG_FILE', MASTER_LOG_POS='$REPL_LOG_POSITION';"

# Start the slave for replication
mysql \
    -u "$MASTER_ROOT_USER" \
    -p"$MASTER_ROOT_PASSWORD" \
    -h"$MASTER_HOSTNAME" \
    -AN \
    -e "START SLAVE;"

# See the slave status
mysql \
    -u "$MASTER_ROOT_USER" \
    -p"$MASTER_ROOT_PASSWORD" \
    -h"$MASTER_HOSTNAME" \
    -AN \
    -e "SHOW SLAVE STATUS;"
