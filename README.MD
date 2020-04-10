# Certbot Scripts

Two scripts are provided in this repository :

-   certbot_sub_domain_port.sh
-   certbot_sub_domain_static.sh

These scripts use the `certbot` program to generate your SSL certificates.

## certbot_sub_domain_port.sh

The script `certbot_sub_domain_port.sh` script allows you to setup HTTPS (SSL/TLS) on a certain forwarded port (useful for API or Docker container for instance).

This script takes 3 arguments :

-   The domain (or sub-domain) of the future URL adress (e.g: myapi.mywebsite.com).
-   An email adress. It'll be used by the the certbot to send you an email in case of an issue with your SSL certificates.
-   The port that need to be forwarded (e.g: 10000).

## certbot_sub_domain_static.sh

The script `certbot_sub_domain_static.sh` script allows you to setup HTTPS (SSL/TLS) for a static website. This website has to be inside the `/var/www/html/` repertory for it to work.

This script takes 3 arguments :

-   The domain (or sub-domain) of the future URL adress (e.g: myapi.mywebsite.com).
-   An email adress. It'll be used by the the certbot to send you an email in case of an issue with your SSL certificates.
-   The name of the static website repertory inside the `/var/www/html` repertory (e.g: if the path to your website folder is `/var/www/html/mywebsite`, the argument will be `mywebsite`).

## Recommndations

Before your run these scripts on your machine, please make sure that you have the execution rights. If not then execute this command :

```
chmod +x certbot_sub_domain_port.sh certbot_sub_domain_static.sh
```

These scripts have only been tested on Ubuntu 18.04.
