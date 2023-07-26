#!/bin/bash

# Define the custom DNS servers you want to use
dns_server1="61.19.42.5"
dns_server2="8.8.8.8"

# Check if the script is running with root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." 
  exit 1
fi

# Replace the existing nameserver entries in /etc/resolv.conf with the custom DNS servers
echo "nameserver $dns_server1" > /etc/resolv.conf
echo "nameserver $dns_server2" >> /etc/resolv.conf

# Rest of the script remains the same...
