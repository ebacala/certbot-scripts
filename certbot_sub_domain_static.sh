#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "Please enter your domain name:"
read -e nginx_domain_name
echo "Please enter your email adress (only used for certbot script):"
read -e nginx_email_address
echo "Please enter the repertory that will be used to store the static website (absolute path):"
read -e nginx_repository

export NGINX_DOMAIN_NAME=${nginx_domain_name}
export NGINX_EMAIL_ADDRESS=${nginx_email_address}
export NGINX_REPOSITORY=${nginx_repository}

apt update
apt install -y software-properties-common
add-apt-repository universe
apt install -y nginx certbot python3-certbot-nginx

# Only kill and restart nginx if it's running
if systemctl is-active --quiet nginx; then
  fuser -k 80/tcp
  service nginx restart
fi

# Check if cert already exists, only run certbot if it doesn't
if [ ! -d "/etc/letsencrypt/live/${NGINX_DOMAIN_NAME}" ]; then
  certbot --nginx certonly -d ${NGINX_DOMAIN_NAME} -m ${NGINX_EMAIL_ADDRESS} --agree-tos --no-eff-email
fi

# Generate DH parameters only if they don't exist
if [ ! -f "/etc/letsencrypt/live/${NGINX_DOMAIN_NAME}/dhparam.pem" ]; then
  openssl dhparam -out /etc/letsencrypt/live/${NGINX_DOMAIN_NAME}/dhparam.pem 2048
fi

# Create nginx config only if it doesn't exist or if template is newer
if [ ! -f "/etc/nginx/sites-available/${NGINX_DOMAIN_NAME}" ]; then
  envsubst '${NGINX_DOMAIN_NAME} ${NGINX_REPOSITORY}' <$DIR/templates/certbot_sub_domain_static.template >/etc/nginx/sites-available/${NGINX_DOMAIN_NAME}
fi

# Create symlink
ln -nfs /etc/nginx/sites-available/${NGINX_DOMAIN_NAME} /etc/nginx/sites-enabled/${NGINX_DOMAIN_NAME}

# Improved TLS v1.3 check and addition
if ! grep -q "TLSv1.3" /etc/nginx/nginx.conf; then
  if grep -q "ssl_protocols" /etc/nginx/nginx.conf; then
    # Only add TLSv1.3 if it's not already in the ssl_protocols line
    TLS_LINE_NUMBER=$(awk '/ssl_protocols/{ print NR; exit }' /etc/nginx/nginx.conf)
    sed -i "${TLS_LINE_NUMBER}s/;/ TLSv1.3;/" /etc/nginx/nginx.conf
    echo "TLS v1.3 added to your nginx global config file"
  else
    # If ssl_protocols line doesn't exist, add it
    echo "ssl_protocols TLSv1.2 TLSv1.3;" >>/etc/nginx/nginx.conf
    echo "Added ssl_protocols with TLS v1.3 to nginx global config file"
  fi
else
  echo "TLS v1.3 is already configured in your nginx global config file"
fi

# Reload the nginx configuration
nginx -s reload
