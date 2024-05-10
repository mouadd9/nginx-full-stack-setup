#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

URL=$1

echo "Entrer le nom du fichier du projet :"
read PROJECT_FOLDER

FULL_PATH="/var/www/html/$PROJECT_FOLDER"

rm -rf "$FULL_PATH"

git clone "$URL" "$FULL_PATH"

echo "Projet importé ici $FULL_PATH"


