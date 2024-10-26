#!/bin/bash

# This script sets up RIP on a node using Quagga/FRRouting.

# Define the interface names
INTERFACE1=$1
INTERFACE2=$2

# Check if enough arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <interface1> <interface2>"
    exit 1
fi

# Update and install required packages
sudo apt-get update
sudo apt-get install -y frr frr-ripd

# Enable RIP in FRRouting configuration
sudo bash -c 'cat >> /etc/frr/frr.conf <<EOL
router rip
 network $INTERFACE1
 network $INTERFACE2
EOL
'

# Set ownership of the configuration file
sudo chown frr:frr /etc/frr/frr.conf

# Start the FRRouting services
sudo systemctl start frr
sudo systemctl enable frr

# Show routing table
echo "RIP configuration completed. Here is the current routing table:"
vtysh -c "show ip route"
