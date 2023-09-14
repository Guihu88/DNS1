#!/bin/bash

# 安装WireGuard工具
sudo apt update
sudo apt install -y wireguard-tools

# 生成WireGuard服务器和客户端密钥对
sudo wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey

# 创建WireGuard服务器配置文件
echo "
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = $(cat /etc/wireguard/privatekey)

[Peer]
PublicKey = <客户端的公钥>
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = 101.36.126.206:58083
PersistentKeepalive = 25
" | sudo tee /etc/wireguard/wg0.conf

# 创建WireGuard客户端配置文件
echo "
[Interface]
PrivateKey = <客户端的私钥>
Address = 10.77.0.2/24
DNS = 8.8.8.8
MTU = 1380

[Peer]
PublicKey = $(cat /etc/wireguard/publickey)
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = 101.36.126.206:58083
PersistentKeepalive = 25
" | sudo tee /etc/wireguard/client.conf

# 启用IPv4转发
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 启动WireGuard服务
sudo wg-quick up wg0

# 设置开机自启
sudo systemctl enable wg-quick@wg0

# 输出服务器配置文件
cat /etc/wireguard/client.conf
