#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Please enter your domain name:"
read nginx_domain_name
echo "Please enter your email adress (only used for certbot script):"
read nginx_email_address
echo "Please enter the the port that needs to be forwarded:"
read nginx_app_port

apt update
apt install -y software-properties-common
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
envsubst '${NGINX_DOMAIN_NAME} ${NGINX_APP_PORT}' < $DIR/templates/certbot_sub_domain_port.template > /etc/nginx/sites-available/${NGINX_DOMAIN_NAME}
ln -s /etc/nginx/sites-available/${NGINX_DOMAIN_NAME} /etc/nginx/sites-enabled/${NGINX_DOMAIN_NAME}

# Copy a new config file
echo "Do you want to update your nginx global config file (you can see this config file in certbot-scripts/conf/nginx.conf) ? (y/n):"
read nginx_update_config
if [[ $nginx_update_config == "y" ]]; then
    cp $DIR/conf/nginx.conf /etc/nginx/nginx.conf
    echo "Your nginx global config file has been updated"
fi

# Reload the nginx configuration
nginx -s reload

