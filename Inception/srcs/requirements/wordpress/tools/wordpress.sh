#!/bin/bash

mkdir -p /run/php

#wget -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
#tar -xzvf/tmp/wordpress.tar.gz -C /var/www/html

chown -R www-data.www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

sed -i 's#listen = /run/php/php7.4-fpm.sock#listen = wordpress:9000#g' /etc/php/7.4/fpm/pool.d/www.conf

mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

sed -i "s/database_name_here/$DATABASE_NAME/" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$MARIADB_USER/" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$MARIADB_PASS/" /var/www/html/wordpress/wp-config.php
sed -i "s/localhost/mariadb:3306/" /var/www/html/wordpress/wp-config.php
sed -i "s/put your unique phrase here/$PHRASE/" /var/www/html/wordpress/wp-config.php

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

wp core install --allow-root --url=$DOMAIN --title=IWantToPass  --admin_user=$WORDPRESS_ADMIN --admin_password=$WORDPRESS_ADMIN_PASS --admin_email=$WORDPRESS_ADMIN_MAIL --skip-email --path=/var/www/html/wordpress

wp user create --allow-root $WORDPRESS_USER $WORDPRESS_USER_MAIL --user_pass=$WORDPRESS_USER_PASS --path=/var/www/html/wordpress --url=$DOMAIN

/usr/sbin/php-fpm7.4 -F
