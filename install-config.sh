#!/bin/bash
echo "nginx....." 
apt-get update
apt-get install -y nginx

echo "php....." 
apt-get install -y \
        php8.3-fpm \
        php8.3-mysql \
        php8.3-curl \
        php8.3-xml \
        php8.3-mbstring \
        php8.3-zip \
        php8.3-intl \
        php8.3-cli 

# Installing additional PHP extensions
apt-get install -y php-mbstring php-zip php-gd php-json php-curl

echo "mysql-server....." 
apt-get install -y mysql-server

echo "phpmyadmin....."
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password password" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password password" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections

export DEBIAN_FRONTEND=noninteractive
apt-get install -y phpmyadmin

echo "Enabling services..."
service nginx restart
service mysql restart
service php8.3-fpm restart

# Enabling PHP extensions
phpenmod mbstring
phpenmod curl
phpenmod gd
phpenmod json
phpenmod zip

# Restart PHP-FPM to apply changes
service php8.3-fpm restart

echo "------------------------------------Installation complete. Services have been enabled."

echo "Configuring Nginx to serve PHP applications..."

cp /app/nginx.conf /etc/nginx/sites-available/default
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
nginx -t
service nginx restart

echo "Updating MySQL Privileges and Verifying User..."

# Extract debian-sys-maint user info from debian.cnf
DEBIAN_MAINT_PASSWORD=$(grep 'password' /etc/mysql/debian.cnf | head -1 | awk -F' = ' '{print $2}')
DEBIAN_MAINT_USER=$(grep 'user' /etc/mysql/debian.cnf | head -1 | awk -F' = ' '{print $2}')

# Configure debian-sys-maint user in MySQL
mysql -u root -e "
CREATE USER IF NOT EXISTS '${DEBIAN_MAINT_USER}'@'localhost' IDENTIFIED BY '${DEBIAN_MAINT_PASSWORD}';
GRANT ALL PRIVILEGES ON . TO '${DEBIAN_MAINT_USER}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
"

mysql -u root "
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('passroot');
FLUSH PRIVILEGES;
"

# Configure new MySQL user and grant privileges
mysql -u root -p -e "
CREATE DATABASE IF NOT EXISTS websiteDB;
CREATE USER IF NOT EXISTS user2@localhost IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON websiteDB.* TO user2@localhost;
FLUSH PRIVILEGES;
"

echo "Now manually configure phpMyAdmin settings by editing config-db.php"

sudo nano /etc/phpmyadmin/config-db.php

echo "---------------------------------configuration complete"
