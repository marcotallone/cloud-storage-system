#!/bin/bash

# Variables
DIR="scripts"
N_USERS=50 # Default number of users

# Check if we are in the right place
if [ ! -d "$DIR" ]; then
    echo "⛔ ERROR: You must run this command from the project's root folder."
    exit 1
fi

# Create the users and upload the test file
./$DIR/add_users.sh $N_USERS
./$DIR/upload.sh $N_USERS
