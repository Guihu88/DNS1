#!/bin/bash

function green() {
    echo -e "\033[32m$1\033[0m"
}

function red() {
    echo -e "\033[31m$1\033[0m"
}

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
    red "请以root用户运行此脚本"
    exit 1
fi

# 安装WireGuard
function install_wireguard() {
    if [[ -e /etc/debian_version ]]; then
        apt-get update
        apt-get install -y wireguard-tools
    elif [[ -e /etc/redhat-release ]]; then
        yum install -y epel-release
        yum install -y wireguard-tools
    else
        red "不支持的操作系统"
        exit 1
    fi
}

# 生成WireGuard配置文件
function generate_wireguard_config() {
    local server_private_key=$(wg genkey)
    local server_public_key=$(echo "$server_private_key" | wg pubkey)
    local server_ip="10.0.0.1/24"
    local listen_port="51820"
    
    # 生成服务端配置文件
    cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $server_private_key
Address = $server_ip
ListenPort = $listen_port
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

EOF

    green "服务端配置文件已生成: /etc/wireguard/wg0.conf"
    
    # 自动生成客户端配置（示例：CLIENT1）
    local client_private_key=$(wg genkey)
    local client_public_key=$(echo "$client_private_key" | wg pubkey)
    cat > /etc/wireguard/client1.conf <<EOF
[Interface]
PrivateKey = $client_private_key
Address = 10.0.0.2/32

[Peer]
PublicKey = $server_public_key
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF
    
    green "客户端配置文件已生成: /etc/wireguard/client1.conf"
    
    # 输出客户端配置信息
    cat /etc/wireguard/client1.conf
}

# 启动WireGuard
function start_wireguard() {
    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0
    green "WireGuard已启动"
}

# 安装WireGuard
install_wireguard

# 生成WireGuard配置文件
generate_wireguard_config

# 启动WireGuard
start_wireguard

green "WireGuard服务器已配置并启动。"
