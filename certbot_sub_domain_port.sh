#!/bin/bash

echo "Please enter your domain name:"
read nginx_domain_name
echo "Please enter your email adress (only used for certbot script):"
read nginx_email_address
echo "Please enter the the port that needs to be forwarded:"
read nginx_app_port

apt update
apt install software-properties-common
add-apt-repository universe
apt install -y nginx certbot python3-certbot-nginx

fuser -k 80/tcp
service nginx restart

export NGINX_DOMAIN_NAME=${nginx_domain_name}
export NGINX_EMAIL_ADDRESS=${nginx_email_address}
export NGINX_APP_PORT=${nginx_app_port}

# Launch Certbot with the domain name and email address defined in the environment variables
certbot --nginx certonly -d ${NGINX_DOMAIN_NAME} -m ${NGINX_EMAIL_ADDRESS} --agree-tos --no-eff-email

# Generate new DH parameters
openssl dhparam -out /etc/letsencrypt/live/${NGINX_DOMAIN_NAME}/dhparam.pem 2048

# Replace the default template file with the environment variables
envsubst '${NGINX_DOMAIN_NAME} ${NGINX_APP_PORT}' < templates/certbot_sub_domain_port.template > /etc/nginx/sites-available/${NGINX_DOMAIN_NAME}
ln -s /etc/nginx/sites-available/${NGINX_DOMAIN_NAME} /etc/nginx/sites-enabled/${NGINX_DOMAIN_NAME}
# Copy a new config file
cp conf/nginx.conf /etc/nginx/nginx.conf

# Reload the nginx configuration
nginx -s reload

