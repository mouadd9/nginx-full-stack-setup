#!/bin/bash

DIRECTORY="/var/www/html/proj"

MYSQL_USER="phpmyadmin"
MYSQL_PASSWORD="password"
DB_NAME="gestion_platforme_scolaire"  

cd "$DIRECTORY"

SQL_FILE=$(find . -type f -name '*.sql' -print -quit)
if [[ -z "$SQL_FILE" ]]; then
    echo "No SQL file found in $DIRECTORY."
    exit 1
else
    echo "Found SQL file: $SQL_FILE"
fi

mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME;
 USE $DB_NAME;
 source $SQL_FILE;
"

echo "bd $DB_NAME cree ,importée de $SQL_FILE."
