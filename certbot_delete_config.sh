#!/bin/bash

echo "Please enter the name of the config file to delete:"
read -e nginx_config_file_name

# Delete Let's Encrypt certificate
certbot delete --cert-name ${nginx_config_file_name}

# Delete Nginx configuration file
rm /etc/nginx/sites-available/${nginx_config_file_name} /etc/nginx/sites-enabled/${nginx_config_file_name}

# Delete Let's Encrypt directory for the configuration file name (because dhparams can still be there)
rm -rf /etc/letsencrypt/live/${nginx_config_file_name}

# Restart Nginx
service nginx restart