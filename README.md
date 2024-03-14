# Inception

Guia Para Inception

Conectarse con ssh

	ssh gromero-@localhost -p 4343

Archivo .env
{
Creamos las variables globlales que necesitaremos luego para no dejar contraseñas ni nada sensible en los dockerfile etc...
}

Cambiar el hostname de localhost para poder entrar con nuestro login.42.fr
{
En el archivo /etc/hosts añadimos la ip del localhost y luego la url que queremos

	127.0.0.1	gromero-.42.fr
}
Instalar Docker Compose
{
Primero necesito instalar curl que sirve para para poder descargar cosas, en este caso un repo de gituhub.
	
 	sudo apt install curl

Nos descargamos el repo de github en /usr/local/bin que es donde se deberian descargar los ejecutables que no viene instalado con linux.

	curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

Le damos los permisos necesarios para su ejecucion.

	chmod +x /usr/local/bin/docker-compose
}

Instalar Docker
{
Instalamos unas dependecias basicas para docker
	
 	apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

Descargamos Docker
	
 	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

Añadimos el repositorio de Docker CE(community edition)
	
 	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

Instalamos Docker CE
	
	apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose

Mirar estado y añadirlo al arranque

 	systemctl status docker
	systemctl enable docker
}

Creamos la estructura de carpetas como en el subject

Docker-compose.yml
{
Version ponemos alguna aunque no estoy seguro
Creamos el container de nginx:
	
	-build: donde esta el dockerfile y va a ejecutar el run
	-container_name: nombre del container que en este caso es nginx
	-restart (MIRAR PARA QUE SIRVE REALMENTE)
	-port: Primero va el puerto del host y luego el del container
 	-env_file : importa el archivo .env para usar las variables globales
  	-depends_on : con esto indicamos que un container depende del otro por lo tanto wordpress depende de mariadb y nginx depende de wordpross y con esto estamos diciendo el orden en el que se van a iniciar los containers, primero mariadb luego wordpress y por ultimo nginx.
	-networks : ponemos eo nombre de la network que hemos creado.
	-expose : para exponer el puerto de los contenedor y no usar port para que no se pueda acceder desde el exterior
	-volumes : con esto ponemos el volumen:/  ponemos el nombre del volumen y la ruta donde queremos montarlo
 
Apartado de networks aparte de services.

	networks:
  		inception:
    			driver: bridge
       (Primero el apartado de networks para declarar que vamos a crear una, lo siguiente es el nombre, en el ultimo apartado vienen las normas que vamos a poner que en este caso es drivers:bridge lo cual es el standar aunque lo ponemos por si acaso, bridge conecta todos los containers entre si, en el mismo host)
}

Apartado de volumenes.

	volumes:
 		mariadb_data:
   			driver: local
    			driver_opts:
      				type: none	
       				device: /home/gromero-/data/mariadb
      				o: bind
   		wordpress_data:
     			driver: local
			driver_opts:
      				type: none	
       				device: /home/gromero-/data/mariadb
      				o: bind
	  
	(Volumes para indicar que es el apartado de volumenes, declaramos los nombre de los volumenes que vamos a crear, driver es para indicar que los datos se guardan en local y no se van a exportar a la nube, con esto los volumenes se deberian de crear si no existen aunque de todas formas se van a crear de forma anterior, driver opts en device ponemos la ruta donde queremos guardar los datos)

Makefile
{
Creamos la regla de name con el comando: (Mirar el -f)
	
 	docker-compose -f srcs/docker-compose.yml up

Creamos la regla clean con el comando: para borrar todo los containers

 	docker system prune -af
}

Creamos el primer Dockerfile para nginx
{
FROM debian:bullsey (From es para indicar la imagen base sobre la que vamos a trabajar que en este caso sera la penultima version estable de debian)
	
 COPY (Usamos copy dos veces una para copiar el scrip a el contenedor y otro para hacer lo propio con la configuracion del server nginx)

RUN O CMD (Con esto podemos hacer que se ejecute un script o comando que queramos, en este caso vamos a utilizarlo para lanzar un script que se encargara de todo)
  GNU nano 2.0.6                    File: README.txt

Comando para lanzar el container

	docker run -it -p 443:443 nginx

Para poder entrar en la terminal del container

	docker exec -it IMAGEN_ID bash

El nginx.conf lo vamos a pegar en el directorio /etc/nginx/ que es el default donde se guarda

	COPY /conf/nginx.conf /etc/nginx/

Para cambiar el hostname y poner gromero-.42.fr tenemos que cambiar el archivo /etc/hosts y$
}

Instalar y configuarar TLS
{
Vamos a añadir con este comando el certificado y la clave privada para hacer la conexion segura

	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=ES/ST=Andalucia/L=Malaga/O=42Network/OU=42Malaga/CN=gromero-.42.fr/UID=gromero-"
   	openssl: para gestionar el propio ssl
    	req: para utilizar x.509 que es un protocolo standar de ssl
     	-x509: para hacer un certificado autofirmado en vez de un signing request
      	-nodes: para skipear el paso de crear un passphrase y no tener que intervenir en la creacion
       	-days 365: duracion del certificado
	-newkey rsa:2048: para crear el certificado y la clave a la vez ademas de darle a la key un tamaño de 2048 bits
 	-keyout: ruta para crear la key
  	-out: ruta para el certificado
   	-subj: para rellenar los datos necesarios sin tener que intervenir y directo desde el script
  
  En el script añadimos el apt-get install openssl, añadimos lo siguiente en el archivo de configuracion nginx
 	
  	listen		443 ssl;
  	ssl_protocols	TLSv1.2 TLSv1.3;
	ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

 	ssl_certificate && ssl_certificate_key: directiva que asocia el certificado y la key
 	listen		443 ssl; añadimos ademas del puerto 443 ssl para que utilize estos puertos
  	ssl_protocols	TLSv1.2 TLSv1.3; añadimos la directiva para que permita tanto v1.2 como v1.3
}

Dockerfie para Mariadb
{
Creamos el dockerfile con lo mismo que nginx lo unico que cambiando comandos y script para instalar mariadb
Tenemos que crear el directoria de /run/mysqld que es donde tendremos que cambiar los permisos del root de mysql

Corremos el script que contiene comandos simples para crear la base de datos y los usuarios
	
 	echo "CREATE DATABASE ${DATABASE_NAME};" > init.sql
	echo "CREATE USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASS}';" >> init.sql
	echo "CREATE USER '${MARIADB_GUEST}'@'%' IDENTIFIED BY '${MARIADB_GUEST_PASS}';" >> init.sql
	echo "GRANT ALL PRIVILEGES ON *.* TO '${MARIADB_USER}'@'%';" >> init.sql
 	En esta parte estamos creando el archivo .sql con los comandos que lanzar cuando iniciemos mariadb(sirven para crear la base de datos y los usuarios con sus respectivos privilegios)
  	chmod 777 init.sql (Damos permisos al archivo .sql)
	mv init.sql /run/mysqld/init.sql (Lo movemos a la ruta donde estara el root de la base de datos)
	chown -R mysql:root /var/run/mysqld (Cambiamos los permisos del directorio de la base de datos a la ruta bajo el root de mysql)
 	mariadbd --init-file /run/mysqld/init.sql (Iniciamos el servicio con mariadbd para que el daemon este off y no se cierre el container y con --init-file hacemos que de inicio lanze el script que hemos creado para crear todo)

En el archivo de configuracion de mysql lo unico importante que cambiar es bind-address = 0,0,0,0 (INVESTIGAR EL POR QUE)
}

Dockerfile para wordpress
{
Tenemos que instalar tanto wordpress com php y para wordpress se necista instalar wget y tar(wget descarga de la pagina de wordpress y con tar descomprimimos el archivo).

Creamos el directorio necesario para que se guarde el pid de php.

	mkdir -p /run/php
 
Cambiamos los permisos del directorio a /var/www/html/wordpress y luego le cambiamos los permisos del directorio.

	chown -R www-data.www-data /var/www/html/wordpress
	chmod -R 755 /var/www/html/wordpress

Cambiamos el nombre del archivo a el que usa wordpress como default con este comando y tenemos que cambiar varias lineas dentro para cambiar los datos y no usar contraseñas dentro del archivo.

	mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

 Con el comando sed (sirve para cambiar texto dentro de un archivo, la primera s/ indica donde se empieza y en el primer caso del puerto se utiliza s# porque ya hay / dentro de lo que vamos a cambiar y la g del final es necesaria cuando cambiamos un /)

	sed -i 's#listen = /run/php/php7.4-fpm.sock#listen = wordpress:9000#g' /etc/php/7.4/fpm/pool.d/www.conf (Cambiamos el puerto por el que escuchamos en wordpress a 9000)
 	sed -i "s/database_name_here/$DATABASE_NAME/" /var/www/html/wordpress/wp-config.php
	sed -i "s/username_here/$MARIADB_USER/" /var/www/html/wordpress/wp-config.php
	sed -i "s/password_here/$MARIADB_PASS/" /var/www/html/wordpress/wp-config.php
	sed -i "s/localhost/mariadb:3306/" /var/www/html/wordpress/wp-config.php (Cambiamos el host a mariadb y le ponemos el puerto)
}

Crear volumenes tanto para wordpress como mariadb
{
Crear volumen con "docker volume create NOMBRE_VOLUMEN"
Los volumenes se guarda en /var/lib/docker/volumes.

}
