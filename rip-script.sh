#!/bin/bash
################################################################################
# Script to configure RIP routing on Quagga
# Modified for Fabric by [Your Name]
################################################################################

# Define constants for configuration files
ZEBRA="/etc/quagga/zebra.conf"
RIPD="/etc/quagga/ripd.conf"
RIPD_TEMP="/tmp/ripd"

# Check if the RIP configuration already exists
if [[ ! -f $RIPD ]]; then
    # Update package list and install Quagga if not installed
    sudo apt-get update
    sudo apt-get -y install quagga traceroute

    # Get the IP addresses of the specified interfaces
    ETH1IP=$(ip addr | grep inet | grep INTERFACE_NAME_1 | awk -F " " '{print $2}')
    ETH2IP=$(ip addr | grep inet | grep INTERFACE_NAME_2 | awk -F " " '{print $2}')

    # Create the Zebra configuration file
    echo "interface lo" | sudo tee $ZEBRA
    echo " description loopback" | sudo tee -a $ZEBRA
    echo " ip address 127.0.0.1/8" | sudo tee -a $ZEBRA
    echo " ip forwarding" | sudo tee -a $ZEBRA
    echo "!" | sudo tee -a $ZEBRA
    echo "interface INTERFACE_NAME_1" | sudo tee -a $ZEBRA
    echo " description INTERFACE_NAME_1" | sudo tee -a $ZEBRA
    echo " ip address $ETH1IP" | sudo tee -a $ZEBRA
    echo " ip forwarding" | sudo tee -a $ZEBRA
    echo "!" | sudo tee -a $ZEBRA
    echo "interface INTERFACE_NAME_2" | sudo tee -a $ZEBRA
    echo " description INTERFACE_NAME_2" | sudo tee -a $ZEBRA
    echo " ip address $ETH2IP" | sudo tee -a $ZEBRA
    echo " ip forwarding" | sudo tee -a $ZEBRA
    echo "log file /var/log/quagga/zebra.log" | sudo tee -a $ZEBRA

    # Create the RIP configuration file
    echo "router rip" | sudo tee $RIPD_TEMP
    echo " version 2" | sudo tee -a $RIPD_TEMP
    echo " network INTERFACE_NAME_1" | sudo tee -a $RIPD_TEMP
    echo " network INTERFACE_NAME_2" | sudo tee -a $RIPD_TEMP
    echo " log file /var/log/quagga/ripd.log" | sudo tee -a $RIPD_TEMP
    sudo mv $RIPD_TEMP $RIPD

    # Adjust ownership and permissions for Quagga configuration files
    sudo chown quagga:quagga $ZEBRA $RIPD
    sudo chmod 640 $ZEBRA $RIPD
fi

# Start the necessary services
sudo systemctl start zebra
sudo systemctl start ripd

# Check the status of the services
sudo systemctl status zebra
sudo systemctl status ripd
