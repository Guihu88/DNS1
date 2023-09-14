#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# Update the system
yum update -y

# Install WireGuard packages
yum install -y epel-release
yum install -y wireguard-tools

# Enable the WireGuard kernel module
modprobe wireguard

# Configure WireGuard
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

# Print QR code for easy client setup
qrencode -t ansiutf8 < /etc/wireguard/wg0.conf

echo "WireGuard has been successfully installed and configured."
echo "Make sure to replace '<YourServerPrivateKey>' and '<YourClientPublicKey>' with your actual keys."
