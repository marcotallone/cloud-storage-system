#!/bin/bash

# File Size (kB)
SIZE=1
BIN="bin"

# Check if we are in the right place
if [ ! -d "$BIN" ]; then
    echo "⛔ ERROR: You must run this command from the project's root folder."
    exit 1
fi

# Create a 1kB file in the folder ./test/uploads/ and in the ./bin/ folder
dd if=/dev/zero of=bin/testfile.txt bs=1024 count=$SIZE
dd if=/dev/zero of=test/uploads/testfile.txt bs=1024 count=$SIZE
dd if=/dev/zero of=test/uploads/1KB.txt bs=1024 count=$SIZE

# Create a 1MB file in the folder ./test/uploads
dd if=/dev/zero of=test/uploads/1MB.txt bs=1024 count=$((1024*$SIZE))

# Create a 1GB file in the folder ./test/uploads
dd if=/dev/zero of=test/uploads/1GB.txt bs=1M count=$((1024*$SIZE))

# Check if the files were created
if [ $? -eq 0 ]; then
    echo "✅ Files created successfully"
else
    echo "⛔ ERROR: Files creation failed. Try running this script from root folder"
fi