#!/bin/bash

# Check if the number of arguments is not equal to 1
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <up|down>"
    exit 1
fi

# Read the first argument from the command line
todo=$1

# Check if the first argument is "up"
if [[ $todo == "up" ]]; then
    sudo virsh net-define kub-devel-network.xml
    sudo virsh net-start kub-devel
    sudo virsh net-autostart kub-devel

# otherwise
else
    sudo virsh net-destroy kub-devel
    sudo virsh net-undefine kub-devel
fi