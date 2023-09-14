#!/bin/bash

function install_wireguard() {
    # Check if WireGuard is already installed
    if ! command -v wg &>/dev/null; then
        # Install WireGuard
        if [[ -f /etc/os-release ]]; then
            source /etc/os-release
            if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then
                apt update
                apt install -y wireguard
            elif [[ "$ID" == "centos" ]]; then
                yum install -y epel-release
                yum install -y wireguard-tools
            else
                echo "Unsupported operating system."
                exit 1
            fi
        else
            echo "Unsupported operating system."
            exit 1
        fi
    fi
}

function generate_wireguard_config() {
    mkdir -p /etc/wireguard
    cd /etc/wireguard || exit

    # Generate server and client keys
    wg genkey | tee server_privatekey | wg pubkey > server_publickey
    wg genkey | tee client_privatekey | wg pubkey > client_publickey

    # Define server and client configuration
    cat > wg0-server.conf <<EOF
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = $(cat server_privatekey)
EOF

    cat > wg0-client.conf <<EOF
[Interface]
PrivateKey = $(cat client_privatekey)
Address = 10.0.0.2/24

[Peer]
PublicKey = $(cat server_publickey)
Endpoint = your_server_ip:51820  # 请替换 your_server_ip 为您的VPS的实际IP地址
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

    # Enable IP forwarding
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p
}

# Main script
install_wireguard
generate_wireguard_config

# Output client configuration
echo "Client configuration (wg0-client.conf):"
cat wg0-client.conf
