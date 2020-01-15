#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo 'You need 2 arguments : the domain name and your email adress';
  exit;
fi

apt update
apt install -y nginx certbot python-certbot-nginx

fuser -k 80/tcp
service nginx restart

export NGINX_DOMAIN_NAME=$1
export NGINX_EMAIL_ADDRESS=$2

# Launch Certbot with the domain name and email address defined in the environment variables
certbot --nginx certonly -d ${NGINX_DOMAIN_NAME} -m ${NGINX_EMAIL_ADDRESS} --agree-tos --no-eff-email

# Replace the default template file with the environment variables
envsubst '${NGINX_DOMAIN_NAME}' < certbot_main_domain.template > /etc/nginx/sites-available/default
ln -s /etc/nginx/sites-available/certbot_main_domain /etc/nginx/sites-enabled/default

# Reload the nginx configuration
nginx -s reload