#!/bin/bash

echo "Enabling services..."
service nginx start
service mysql start
service php8.3-fpm start

echo "Configuring Nginx to serve PHP applications..."

cp /app/nginx.conf /etc/nginx/sites-available/default
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
nginx -t
service nginx restart

echo "Updating MySQL Privileges..."

SQL_COMMANDS="
CREATE USER IF NOT EXISTS 'phpmyadmin'@'localhost' IDENTIFIED BY 'password';
ALTER USER 'phpmyadmin'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
CREATE DATABASE db;
exit
"
echo "$SQL_COMMANDS" | mysql

sudo sed -i "s/localhost/127.0.0.1/g" /etc/phpmyadmin/config-db.php
nano /etc/phpmyadmin/config-db.php

echo "Installation and configuration complete. Services have been enabled."
