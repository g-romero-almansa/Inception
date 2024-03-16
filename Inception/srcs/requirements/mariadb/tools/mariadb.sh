#!/bin/bash

echo "CREATE DATABASE ${DATABASE_NAME};" > init.sql
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASS}';" >> init.sql
echo "CREATE USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASS}';" >> init.sql
echo "GRANT ALL PRIVILEGES ON *.* TO '${MARIADB_USER}'@'%';" >> init.sql
echo "FLUSH PRIVILEGES;" >> init.sql

chmod 777 init.sql
mv init.sql /run/mysqld/init.sql
chown -R mysql:root /var/run/mysqld

mariadbd --init-file /run/mysqld/init.sql
