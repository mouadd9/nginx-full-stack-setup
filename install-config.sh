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
service nginx start
service mysql start
service php8.3-fpm start

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
GRANT ALL PRIVILEGES ON *.* TO '${DEBIAN_MAINT_USER}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
"



echo "Updating MySQL Privileges and Creating New User..."

# Prompt user for MySQL new user credentials
echo "Enter new MySQL user name:"
read NEW_USER
echo "Enter password for new MySQL user:"
read NEW_PASS

# Configure new MySQL user and grant privileges
mysql -u root -e "
CREATE USER IF NOT EXISTS '${NEW_USER}'@'127.0.0.1' IDENTIFIED BY '${NEW_PASS}';
GRANT ALL PRIVILEGES ON *.* TO '${NEW_USER}'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS db;
"

# Ensure phpMyAdmin uses IP address instead of 'localhost'
sudo sed -i "s/'localhost'/'127.0.0.1'/g" /etc/phpmyadmin/config-db.php

echo "Now manually configure phpMyAdmin settings by editing config-db.php"

sudo nano /etc/phpmyadmin/config-db.php

echo "---------------------------------configuration complete"
