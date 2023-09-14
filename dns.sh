v#!/bin/bash
# WireGuard一键安装脚本 for CentOS/Ubuntu/Debian

function green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
function red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

function check_installation() {
    if ! command -v wg &>/dev/null; then
        green "WireGuard未安装，开始安装..."
        install_wireguard
    else
        green "WireGuard已安装，继续..."
    fi
}

function install_wireguard() {
    source /etc/os-release
    if [[ "$ID" == "centos" ]]; then
        yum install -y epel-release
        yum install -y wireguard-tools
    elif [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        apt-get update
        apt-get install -y wireguard-tools
    else
        red "不支持的操作系统"
        exit 1
    fi
}

function get_vps_ip() {
    # 获取VPS的公共IP地址
    VPS_IP=$(curl -s https://ipinfo.io/ip)
}

function configure_wireguard() {
    green "开始配置WireGuard服务器..."

    # 获取VPS的公共IP地址
    get_vps_ip

    # 创建WireGuard配置目录
    mkdir -p /etc/wireguard
    cd /etc/wireguard

    # 生成服务器端私钥和公钥
    umask 077
    wg genkey | tee privatekey | wg pubkey > publickey
    server_private_key=$(cat privatekey)
    server_public_key=$(cat publickey)

    # 生成默认的服务器端配置文件
    cat > wg0.conf <<-EOF
[Interface]
PrivateKey = $server_private_key
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = $server_public_key
AllowedIPs = 10.0.0.2/32
EOF

    # 启动WireGuard
    wg-quick up wg0
    systemctl enable wg-quick@wg0

    green "WireGuard服务器配置完成。"

    # 生成客户端配置文件
    generate_client_config
}

function generate_client_config() {
    green "生成WireGuard客户端配置文件..."

    # 创建客户端配置文件目录
    mkdir -p ~/wireguard-client-configs
    cd ~/wireguard-client-configs

    # 生成客户端密钥对
    umask 077
    wg genkey | tee client_private_key | wg pubkey > client_public_key
    client_private_key=$(cat client_private_key)
    client_public_key=$(cat client_public_key)

    # 生成客户端配置文件
    cat > client.conf <<-EOF
[Interface]
PrivateKey = $client_private_key
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = $server_public_key
Endpoint = $VPS_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

    green "WireGuard客户端配置文件已生成。请将client.conf文件复制到您的客户端设备上，并使用WireGuard客户端加载。"
}

check_installation
configure_wireguardvvvv
