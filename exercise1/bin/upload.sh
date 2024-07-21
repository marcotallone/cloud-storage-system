#!/bin/bash

# Variables
URL="https://localhost"
BIN="bin"
FILE="testfile.txt"
N=1
NAME_ROOT="user"
PASSWORD_ROOT="PassaparolaSuperSegreta"

# Check if we are in the right place
if [ ! -d "$BIN" ]; then
    echo "⛔ ERROR: You must run this command from the project's root folder."
    exit 1
fi

# Check if the Nextcloud container is up
if ! docker ps | grep -q app; then
    echo "⛔ ERROR: The Nextcloud container is not running."        
    exit 1
fi

# Override the default number of users if provided
if [ $# -eq 1 ] && [[ $1 =~ ^[0-9]+$ ]]; then
    N=$1
fi

# Override the default file if provided as second argument
if [ $# -eq 2 ]; then
    FILE=$2
fi

# Check that the file exists in the bin folder
if ! [ -f "$BIN/$FILE" ]; then
    echo "⛔ ERROR: The file $BIN/$FILE does not exist. Try running get_file.sh first."        
    exit 1
fi

echo ""
echo "🚀 Uploading files..."

# Upload file inside the container /var/ folder
docker cp $BIN/$FILE app:/var/www/html/$FILE

# Upload file for each user
for i in $(seq $N); do
    NAME="${NAME_ROOT}${i}"
    PASSWORD="${PASSWORD_ROOT}${i}"
    curl -k -u $NAME:$PASSWORD -X PUT -T $BIN/$FILE $URL/remote.php/dav/files/$NAME/$FILE
    if [ $? -eq 0 ]; then
        echo "✅ Upload of file $BIN/$FILE for user $NAME was successful."
    else
        echo "⛔ ERROR: Upload of file $BIN/$FILE for user $NAME failed."      
    fi
done