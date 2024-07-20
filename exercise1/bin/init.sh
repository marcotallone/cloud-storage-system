#!/bin/bash

# Variables
BIN="bin"
N_USERS=20 # Default number of users

# Check if we are in the right place
if [ ! -d "$BIN" ]; then
    echo "⛔ ERROR: You must run this command from the project's root folder."
    exit 1
fi

# Create the users and upload the test file
./bin/add_users.sh $N_USERS
./bin/upload.sh $N_USERS