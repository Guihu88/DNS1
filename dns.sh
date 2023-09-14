#!/bin/bash

function green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

function install_wireguard() {
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
Endpoint = <YOUR_SERVER_IP>:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

    green "配置文件已生成，客户端配置请修改<YOUR_SERVER_IP>为服务器公网IP。"
}

function enable_wireguard() {
    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0
    green "WireGuard配置已生效，无需重启。"
}

# Main script
install_wireguard
generate_wireguard_config
enable_wireguard
