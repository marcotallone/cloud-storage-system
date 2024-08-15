#!/bin/bash

DIR="test"

# Check if we are in the right place
if [ ! -d "$DIR" ]; then
r   echo "⛔ ERROR: You must run this command from the project's root folder."
    exit 1
fi

# Remove the test/uploads and test/downloads directories
rm -rf test/uploads
rm -rf test/downloads

# Remove all docker volumes
docker volume prune -af
