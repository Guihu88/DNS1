#!/bin/bash

# 安装WireGuard
sudo yum install -y epel-release
sudo yum install -y wireguard-tools

# 生成服务端私钥和公钥
server_private_key=$(wg genkey)
server_public_key=$(echo "$server_private_key" | wg pubkey)

# 生成客户端私钥和公钥
client_private_key=$(wg genkey)
client_public_key=$(echo "$client_private_key" | wg pubkey)

# 生成随机端口号
random_port=$(shuf -i 1024-65535 -n 1)

# 创建WireGuard服务端配置文件
sudo tee /etc/wireguard/wg0-server.conf <<EOL
[Interface]
PrivateKey = $server_private_key
Address = 10.0.0.1/24
ListenPort = $random_port

[Peer]
PublicKey = $client_public_key
AllowedIPs = 10.0.0.2/32
EOL

# 创建WireGuard客户端配置文件
sudo tee /etc/wireguard/wg0-client.conf <<EOL
[Interface]
PrivateKey = $client_private_key
Address = 10.0.0.2/24

[Peer]
PublicKey = $server_public_key
AllowedIPs = 0.0.0.0/0
Endpoint = 127.0.0.1:$random_port
EOL

# 输出客户端配置文件内容
cat /etc/wireguard/wg0-client.conf

# 启用IP转发
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 启动WireGuard服务
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0

# 防火墙规则设置（适用于firewalld）
sudo firewall-cmd --zone=public --add-port=$random_port/udp --permanent
sudo firewall-cmd --zone=public --add-masquerade --permanent
sudo firewall-cmd --reload

# 完成
echo "WireGuard服务器和客户端已成功安装和配置！"
