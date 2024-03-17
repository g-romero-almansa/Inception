Guide for Inception

Connect with ssh through port 4343 as the subject request.

    ssh gromero-@localhost -p 4343

Makefile with just a few rules to set up all containers, delete all containers images and networks and to put down and then up all containers.

    docker-compose -f srcs/docker-compose.yml build
    docker-compose -f srcs/docker-compose.yml up
    docker-compose -f srcs/docker-compose.yml down
    docker system prune -af
    With build you force a rebuild for the images (-f path to docker-compose that is not in the directory)
    With up you start the and set up the containers
    With down you remove the containers and networks
    With prune you delete all images, containers and networks(-a remove unused images too, -f do not prompt confirmation)
    
Docker-Compose.yml, with this file we can run all containers at the same time and connect all together

    Version(Not supported for new versions, so doesn't matter what you put)
    Services(Declaring the services/containers, example mariadb:)
    Build(Path to dockerfile where is the configuration for the service)
    Env_file(Adds environment variables to the container based on your file)
    Container_name(Set the containers name instead of default name)
    Restart(Define what to do when container end, unless-stopped indicates it always restart no matter what exit code has but stop when the service is removed or stopped)
    Ports(Expose ports, the first one is the host port exposed and the second its the container port)
    Expose(Exposes ports but only to the other services not the host machine)
    Depends_on(Set the start and shutdown dependencies and order, example here wordpress depend on mariadb and nginx on wordpress so the order its mariadb-wordpress-nginx)
    Networks(Define the name of the network and driver on bridge mode means that the services on that network can communicate and are isolates from the other outside the network)
    Volumes(Define the name of the volume, with driver local you mean the volume info will be store locally, driver opts type and o are set to default and the important its device option wich indicates the path to store info)

ENV file has every credential, password etc... This will be used on services to not post any private info

Dockerfile information

    FROM(Initializes a new build stage from an image, in all the dockerfile is debian::bullseye as required on the subject)
    RUN(This will executes commands on the image, almost every case is for installing the services, example apt-get install nginx)
    COPY(Copy files from the machine to the container, most of them are for copying scripts)
    EXPOSE(Specified port to listen and the run time, probably not necessary if you use expose on the docker-compose)
    CMD(Instruction to set a command execute when the container its running, all we use its for executing scripts on the container, example CMD ["sh", "nginx.sh"])
    
Nginx container

Dockerfile has the run to install nginx and openssl, copy for configuration file and the script, the expose of the port and cmd for running the script.

The script does the following

    #!/bin/bash
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $PATH_KEY -out $PATH_CERTIFICATE -subj     "/C=$COUNTRY/ST=$ST/L=$L/O=$OU/OU=$OU/CN=$DOMAIN/UID=$LOGIN"(Creates the certificate and the key of openssl to do secure connection on the web site)
    sed -i "s/domain/$DOMAIN/" /etc/nginx/nginx.conf(These three lines change credentials on the conf file so they are not uploaded on github)
    sed -i "s#path_certificate#$PATH_CERTIFICATE#g" /etc/nginx/nginx.conf
    sed -i "s#path_key#$PATH_KEY#g" /etc/nginx/nginx.conf
    nginx -g "daemon off;"(Set daemon off so the container run on the background and doesn't exit)
    
The configuration has the following

    events	{}
    http	{
	    server {
		    listen		443 ssl;
		    server_name	domain;
		    ssl_protocols	TLSv1.2 TLSv1.3;
		    ssl_certificate path_certificate;
            ssl_certificate_key path_key;
		    root            /var/www/html/wordpress;
            index           index.php;
		    include       /etc/nginx/mime.types;
		    location ~ \.php$ {
		    	try_files $uri =404;
		    	fastcgi_pass wordpress:9000;
		    	include fastcgi_params;
		    	fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		    }
	    }
    }

Mariadb container

Dockerfile has the run to install mariadb server and create the /run/mysqld for storing the socket, copy for configuration file and the script, the expose of the port and cmd for running the script.

The script does the following

    #!/bin/bash
    echo "CREATE DATABASE ${DATABASE_NAME};" > init.sql(All this commands create a .sql file wich is used at the start of mariadb, its create the database, change root password, create another user and gives it privilages, and flush privilages to make changes without restarting mariadb)
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASS}';" >> init.sql
    echo "CREATE USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASS}';" >> init.sql
    echo "GRANT ALL PRIVILEGES ON *.* TO '${MARIADB_USER}'@'%';" >> init.sql
    echo "FLUSH PRIVILEGES;" >> init.sql
    chmod 777 init.sql(Gives permision to execute the file)
    mv init.sql /run/mysqld/init.sql(Moves the init.sql file to the given path)
    chown -R mysql:root /var/run/mysqld(Change the owner of directory and files with -R to the mysql root of the directory and all files of /var/run/mysqld)
    mariadbd --init-file /run/mysqld/init.sql(Initialized the database with daemon off mariadbd and launch init.sql script and the start thanks to --init-file)

The configuration has the following

    [mysqld]
    user		= mysql
    pid-file	= /run/mysqld/mysqld.pid
    socket		= /run/mysqld/mysqld.sock
    port		= 3306
    basedir		= /usr
    datadir		= /var/lib/mysql
    tmpdir		= /tmp
    bind-address = 0.0.0.0
    Its a shorter configuration file, but has the same as the default conf file except for bind-address wich was localhost IP and change it to 0.0.0.0 so its listen connections for all not only localhost
    
Wordpress container

Dockerfile has the run to  create the default root folder of web servers /var/www/html, install php php-mysql php-fpm mariadb-client wget tar wordpress and download wordpress with wget and decompress it with tar in /var/www/html, copy for the script, the expose of the port and cmd for running the script.

The script does the following

	#!/bin/bash
 	mkdir -p /run/php(The same as mariadb, create this directory for the pid of php)
	chown -R www-data.www-data /var/www/html/wordpress(Change the user and group permission to www-data.www-data on the directory)
	chmod -R 755 /var/www/html/wordpress(Gives permission to the directory)
	sed -i 's#listen = /run/php/php7.4-fpm.sock#listen = wordpress:9000#g' /etc/php/7.4/fpm/pool.d/www.conf(Change the port wordpress listen)
	mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php(Change the name of file to default wordpress conf file)
	sed -i "s/database_name_here/$DATABASE_NAME/" /var/www/html/wordpress/wp-config.php(All of this is to change credentials to env variables and not leek them on github)
	sed -i "s/username_here/$MARIADB_USER/" /var/www/html/wordpress/wp-config.php
	sed -i "s/password_here/$MARIADB_PASS/" /var/www/html/wordpress/wp-config.php
	sed -i "s/localhost/mariadb:3306/" /var/www/html/wordpress/wp-config.php
	sed -i "s/put your unique phrase here/$PHRASE/" /var/www/html/wordpress/wp-config.php
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar(Install wp command line)
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp(This tow lines are for being able to write wp, so we give permison to wp-cli.phar and move it to the path and being able to execute it)
	wp core install --allow-root --url=$DOMAIN --title=IWantToPass  --admin_user=$WORDPRESS_ADMIN --	admin_password=$WORDPRESS_ADMIN_PASS --admin_email=$WORDPRESS_ADMIN_MAIL --skip-email --path=/var/www/html/wordpress(This just do the configuration by command line with wp and to not leek again credentials)
	wp user create --allow-root $WORDPRESS_USER $WORDPRESS_USER_MAIL --user_pass=$WORDPRESS_USER_PASS --path=/var/www/html/wordpress --url=$DOMAIN(This creates another user for wordpress with command line and not leek credentials)
	/usr/sbin/php-fpm7.4 -F (Start php with daemon off)















 

