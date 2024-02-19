# Inception

Guia Para Inception

Conectarse con ssh

ssh gromero-@localhost -p 4343

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

}

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

	RUN O CMD (Con esto podemos hacer que se ejecute un script o comando que queramos, en este c
aso vamos a utilizarlo para lanzar un script que se encargara de todo)
  GNU nano 2.0.6                    File: README.txt

        docker run -it -p 443:443 nginx

        Para poder entrar en la terminal del container
        docker exec -it IMAGEN_ID bash

        El nginx.conf lo vamos a pegar en el directorio /etc/nginx/ que es el default donde se guar$
        COPY /conf/nginx.conf /etc/nginx/

        Para cambiar el hostname y poner gromero-.42.fr tenemos que cambiar el archivo /etc/hosts y$
}

Instalar y configuarar TLS
{

}
