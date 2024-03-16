FROM debian:bullseye

RUN apt-get update -y && apt-get upgrade -y && apt-get install mariadb-server -y
RUN mkdir -p /run/mysqld/

COPY /tools/mariadb.sh .
COPY /tools/50-server.cnf /etc/mysql/mariadb.conf.d/

EXPOSE 3306

CMD ["sh", "mariadb.sh"]
