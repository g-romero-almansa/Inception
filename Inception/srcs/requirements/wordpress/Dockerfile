FROM debian:bullseye

RUN mkdir -p /var/www/html
RUN apt-get update -y && apt-get upgrade -y \
&& apt-get install php php-mysql php-fpm -y && apt-get -y install mariadb-client\
&& apt-get install wget -y && apt-get install tar -y
RUN wget -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz \
&& tar -xzvf/tmp/wordpress.tar.gz -C /var/www/html

COPY /tools/wordpress.sh .

EXPOSE 9000

CMD ["sh", "wordpress.sh"]
