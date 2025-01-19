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
if [ ! -d "/etc/letsencrypt/live/${nginx_domain_name}" ]; then
  certbot --nginx certonly -d ${nginx_domain_name} -m ${nginx_email_address} --agree-tos --no-eff-email
fi

# Generate DH parameters only if they don't exist
if [ ! -f "/etc/letsencrypt/live/${nginx_domain_name}/dhparam.pem" ]; then
  openssl dhparam -out /etc/letsencrypt/live/${nginx_domain_name}/dhparam.pem 2048
fi

# Create nginx config only if it doesn't exist or if template is newer
if [ ! -f "/etc/nginx/sites-available/${nginx_domain_name}" ]; then
  envsubst '${nginx_domain_name} ${nginx_repository}' <$DIR/templates/certbot_sub_domain_static.template >/etc/nginx/sites-available/${nginx_domain_name}
fi

# Create symlink
ln -nfs /etc/nginx/sites-available/${nginx_domain_name} /etc/nginx/sites-enabled/${nginx_domain_name}

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
