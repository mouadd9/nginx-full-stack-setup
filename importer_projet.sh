#!/bin/bash

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

# Take the URL from the first argument
URL=$1

# Remove the existing directory
rm -r /var/www/html*

# Clone the repository from the provided URL into /var/www/html
git clone $URL /var/www/html/proj


