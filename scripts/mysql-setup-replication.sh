#! /bin/bash

set -x

apt-get update
apt-get install mysql-client -y --no-install-recommends

sleep 15

mysql \
    -u"$MASTER_ROOT_USER" \
    -p"$MASTER_ROOT_PASSWORD" \
    -h"$MASTER_HOSTNAME" \
    -AN \
    -e "CREATE USER '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"

mysql \
    -u"$MASTER_ROOT_USER" \
    -p"$MASTER_ROOT_PASSWORD" \
    -h"$MASTER_HOSTNAME" \
    -AN \
    -e "GRANT REPLICATION SLAVE ON *.* TO '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME' IDENTIFIED BY '$SLAVE_REPL_PASSWORD';"

mysql \
    -u"$MASTER_ROOT_USER" \
    -p"$MASTER_ROOT_PASSWORD" \
    -h"$MASTER_HOSTNAME" \
    -AN \
    -e "FLUSH PRIVILEGES;"

mysql \
    -u"$MASTER_ROOT_USER" \
    -p"$MASTER_ROOT_PASSWORD" \
    -h"$MASTER_HOSTNAME" \
    -AN \
    -e "SHOW GRANTS FOR '$SLAVE_REPL_USER'@'$SLAVE_HOSTNAME';"
