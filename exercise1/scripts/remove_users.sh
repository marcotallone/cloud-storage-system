#!/bin/bash

# Variables
URL="https://localhost"
N=1
NAME_ROOT="user"
PASSWORD_ROOT="PassaparolaSuperSegreta"

# Check if the Nextcloud container is up
if ! docker ps | grep -q app; then
    echo "⛔ ERROR: The Nextcloud container is not running."        
    exit 1
fi

# Override the default number of users if provided
if [ $# -eq 1 ] && [[ $1 =~ ^[0-9]+$ ]]; then
    N=$1
fi

echo ""
echo "🚀 Removing users..."

# Delete users
for i in $(seq $N); do
    NAME="${NAME_ROOT}${i}"
    PASSWORD="${PASSWORD_ROOT}${i}"
    docker exec -i -u 33 app bash -c "export OC_PASS=$PASSWORD && /var/www/html/occ user:delete $NAME"
done
