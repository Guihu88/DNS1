#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Install WireGuard
function install_wireguard() {
    # Check the Linux distribution
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case $ID in
            debian|ubuntu)
                apt-get update
                apt-get install -y wireguard
                ;;
            centos)
                yum install -y epel-release
                yum install -y wireguard-tools
                ;;
            *)
                echo "Unsupported distribution: $ID"
                exit 1
                ;;
        esac
    else
        echo "Unsupported distribution."
        exit 1
    fi
}

# Generate WireGuard configuration
function generate_config() {
    mkdir -p /etc/wireguard
    cd /etc/wireguard

    # Server configuration
    wg genkey | tee privatekey | wg pubkey > publickey
    cat > wg0.conf <<-EOF
[Interface]
PrivateKey = $(cat privatekey)
Address = 10.77.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
DNS = 8.8.8.8
MTU = 1420
EOF

    # Client configuration (sample)
    wg genkey | tee privatekey-client | wg pubkey > publickey-client
    cat > client.conf <<-EOF
[Interface]
PrivateKey = $(cat privatekey-client)
Address = 10.77.0.2/32
DNS = 8.8.8.8
MTU = 1420

[Peer]
PublicKey = $(cat publickey)
Endpoint = your_server_ip:51820
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

    # Enable IP forwarding
    echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-wireguard.conf
    sysctl --system

    # Start WireGuard
    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0

    # Display configuration
    echo "WireGuard server is running."
    echo "Server configuration: /etc/wireguard/wg0.conf"
    echo "Sample client configuration: /etc/wireguard/client.conf"
}

# Run the installation and configuration
install_wireguard
generate_config

echo "WireGuard setup completed."
