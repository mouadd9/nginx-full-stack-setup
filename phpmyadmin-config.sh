#!/bin/bash

# Open the phpMyAdmin configuration file for editing
echo "Opening phpMyAdmin configuration file for editing..."

nano /etc/phpmyadmin/config-db.php

# Prompt for MySQL root password
echo "Enter MySQL root password:"
read -s MYSQL_ROOT_PASSWORD

# Log into MySQL as root and execute the commands
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "
DROP USER IF EXISTS 'phpmyadmin'@'127.0.0.1';
CREATE USER 'phpmyadmin'@'127.0.0.1' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
exit
"
sudo service nginx restart

echo "phpMyAdmin user has been configured."
