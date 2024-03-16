#!/bin/bash

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $PATH_KEY -out $PATH_CERTIFICATE -subj "/C=$COUNTRY/ST=$ST/L=$L/O=$OU/OU=$OU/CN=$DOMAIN/UID=$LOGIN"

sed -i "s/domain/$DOMAIN/" /etc/nginx/nginx.conf
sed -i "s#path_certificate#$PATH_CERTIFICATE#g" /etc/nginx/nginx.conf
sed -i "s#path_key#$PATH_KEY#g" /etc/nginx/nginx.conf

nginx -g "daemon off;"
