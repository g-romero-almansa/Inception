FROM debian:bullseye

RUN apt-get update -y && apt-get upgrade -y && apt-get install nginx -y && apt-get install openssl -y
COPY /conf/nginx.conf /etc/nginx/nginx.conf
COPY /tools/nginx.sh .

EXPOSE 443

CMD ["sh", "nginx.sh"]
