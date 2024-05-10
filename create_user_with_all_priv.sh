#!/bin/bash

# Prompt for MySQL root password
echo "Enter MySQL root password:"
read -s MYSQL_ROOT_PASSWORD

# Prompt for new user name
echo "Enter new MySQL user name:"
read NEW_USER

# Prompt for new user password
echo "Enter new MySQL user password:"
read -s NEW_USER_PASSWORD

# Command to create a new user and grant all privileges
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "
CREATE USER '$NEW_USER'@'127.0.0.1' IDENTIFIED BY '$NEW_USER_PASSWORD';
GRANT ALL PRIVILEGES ON . TO '$NEW_USER'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
exit
"
sudo service nginx restart

echo "MySQL user created and granted all privileges."
