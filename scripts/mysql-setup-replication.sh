#! /bin/bash

apt-get -qq update
apt-get install mysql-client -y --no-install-recommends

sleep 30

mysql \
    -u "$MYSQL_MASTER_USER" \
    -p "$MYSQL_MASTER_PASSWORD" \
    -h "$MYSQL_MASTER_HOSTNAME" \
    -AN \
    -e "CREATE USER '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"

mysql \
    -u "$MYSQL_MASTER_USER" \
    -p "$MYSQL_MASTER_PASSWORD" \
    -h "$MYSQL_MASTER_HOSTNAME" \
    -AN \
    -e "GRANT REPLICATION SLAVE ON *.* TO '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"

mysql \
    -u "$MYSQL_MASTER_USER" \
    -p "$MYSQL_MASTER_PASSWORD" \
    -h "$MYSQL_MASTER_HOSTNAME" \
    -AN \
    -e "FLUSH PRIVILEGES;"
