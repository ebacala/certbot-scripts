#!/bin/bash

if [[ $# -ne 3 ]]; then
  echo 'You need 3 arguments : your subdomain name (please include your domain), your email adress and the port that needs to be forwarded';
  exit;
fi

apt update
apt install -y nginx certbot python-certbot-nginx

fuser -k 80/tcp
service nginx restart

export NGINX_DOMAIN_NAME=$1
export NGINX_EMAIL_ADDRESS=$2
export NGINX_APP_PORT=$3

# Launch Certbot with the domain name and email address defined in the environment variables
certbot --nginx certonly -d ${NGINX_DOMAIN_NAME} -m ${NGINX_EMAIL_ADDRESS} --agree-tos --no-eff-email

# Replace the default template file with the environment variables
envsubst '${NGINX_DOMAIN_NAME} ${NGINX_SUB_DOMAIN_NAME} ${NGINX_APP_PORT}' < certbot_sub_domain.template > /etc/nginx/sites-available/${NGINX_DOMAIN_NAME}
ln -s /etc/nginx/sites-available/${NGINX_DOMAIN_NAME} /etc/nginx/sites-enabled/${NGINX_DOMAIN_NAME}
# Copy a new config file
cp nginx.conf /etc/nginx/nginx.conf

# Reload the nginx configuration
nginx -s reload