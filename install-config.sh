#!/bin/bash


apt-get update

echo "----------------------------------------------on install le serveurweb (nginx) et une SGBDR Mysql et les dependences php et phpmyadmin"



echo "1- installation nginx"
apt-get install -y nginx


echo "installation des dependences php" 
apt-get install -y \
        php8.3-fpm \
        php8.3-mysql \
        php8.3-curl \
        php8.3-xml \
        php8.3-mbstring \
        php8.3-zip \
        php8.3-intl \
        php8.3-cli 


echo "2-installation du Mysql-server"
apt-get install -y mysql-server


echo "phpmyadmin....."
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password password" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password password" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections

# on selectionne none car on travail avec nginx 

export DEBIAN_FRONTEND=noninteractive

echo "installation phpmyadmin"
apt-get install -y phpmyadmin


echo "activation des services..."
service nginx restart
service mysql restart
service php8.3-fpm restart

# activation des extensions PHP
phpenmod mbstring
phpenmod curl
phpenmod gd
phpenmod json
phpenmod zip

service php8.3-fpm restart

echo "-------------------------------------------Installation complete. Services have been enabled."

echo "Configuration Nginx pour servir les pages PHP"

# we replace the content of default with new configuration
cp /app/nginx.conf /etc/nginx/sites-available/default

# we delete the symbolic link  and files in sites-enabled of default
rm -f /etc/nginx/sites-enabled/default

# we create a symbolic from sites-available to sites-enabled
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

nginx -t
# en test et redemare le service
service nginx restart

echo "-------------------------------------------configuration complete"
