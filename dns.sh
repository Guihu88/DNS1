#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$EUID" -ne 0 ]; then
  echo "请以root用户或使用sudo运行此脚本"
  exit
fi

# 安装WireGuard工具
apt update
apt install -y wireguard-tools

# 生成WireGuard服务器私钥
server_private_key=$(wg genkey)

# 创建WireGuard服务器配置文件
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = $server_private_key
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

EOF

# 生成WireGuard客户端私钥
client_private_key=$(wg genkey)

# 生成WireGuard客户端公钥
client_public_key=$(echo "$client_private_key" | wg pubkey)

# 创建WireGuard客户端配置文件
cat <<EOF > /etc/wireguard/client.conf
[Interface]
PrivateKey = $client_private_key
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = $(cat /etc/wireguard/wg0.conf | grep "PublicKey" | cut -d " " -f 3)
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $(curl ifconfig.me):51820
PersistentKeepalive = 25
EOF

# 启用IPv4转发
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# 启动WireGuard服务
wg-quick up wg0

# 设置开机自启
systemctl enable wg-quick@wg0

# 输出客户端配置文件
cat /etc/wireguard/client.conf

echo "WireGuard配置已完成。客户端配置文件位于 /etc/wireguard/client.conf。"
