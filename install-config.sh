#!/bin/bash
echo "Updating system..."
apt-get update
apt-get install -y nginx php8.3-fpm php8.3-mysql php8.3-curl php8.3-xml php8.3-mbstring php8.3-zip php8.3-intl php8.3-cli mysql-server

echo "Preseeding debconf for phpMyAdmin..."
echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect none' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/dbconfig-install boolean false' | debconf-set-selections

echo "Installing phpMyAdmin..."
apt-get install -y phpmyadmin

echo "Services are being started..."
service nginx start
service mysql start
service php8.3-fpm start

echo "Configuring Nginx for PHP applications..."
cp /app/nginx.conf /etc/nginx/sites-available/default
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
nginx -t
service nginx restart

echo "Configuring MySQL..."
SQL_COMMANDS="
CREATE USER IF NOT EXISTS 'phpmyadmin'@'localhost' IDENTIFIED BY 'password';
ALTER USER 'phpmyadmin'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
CREATE DATABASE db;
exit
"
echo "$SQL_COMMANDS" | mysql -u root -p

sudo sed -i "s/localhost/127.0.0.1/g" /etc/phpmyadmin/config-db.php
nano /etc/phpmyadmin/config-db.php

echo "Configuration complete!"
