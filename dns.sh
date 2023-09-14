#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# Update the system and install necessary packages
yum update -y
yum install -y epel-release
yum install -y wireguard-tools qrencode

# Check if the WireGuard kernel module is loaded
if ! lsmod | grep wireguard &>/dev/null; then
   modprobe wireguard
fi

# Create WireGuard configuration file
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = <YourServerPrivateKey>
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <YourClientPublicKey>
AllowedIPs = 10.0.0.2/32
EOF

# Start and enable the WireGuard service
systemctl start wg-quick@wg0
systemctl enable wg-quick@wg0

# Check if qrencode is installed and display QR code for client configuration
if command -v qrencode &>/dev/null; then
   qrencode -t ansiutf8 < /etc/wireguard/wg0.conf
else
   echo "qrencode is not installed. You can install it to display QR code for client configuration."
fi

echo "WireGuard has been successfully installed and configured."
echo "Make sure to replace '<YourServerPrivateKey>' and '<YourClientPublicKey>' with your actual keys."
