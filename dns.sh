#!/bin/bash

# 检查是否已安装WireGuard
if ! [ -x "$(command -v wg)" ]; then
  echo "WireGuard 未安装，请手动安装后重新运行脚本。"
  exit 1
fi

# 生成服务端私钥和公钥
server_private_key=$(wg genkey)
server_public_key=$(echo "$server_private_key" | wg pubkey)

# 生成客户端私钥和公钥
client_private_key=$(wg genkey)
client_public_key=$(echo "$client_private_key" | wg pubkey)

# 生成服务端和客户端配置文件
cat <<EOF | sudo tee /etc/wireguard/wg0-server.conf
[Interface]
PrivateKey = $server_private_key
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = $client_public_key
AllowedIPs = 10.0.0.2/32
EOF

cat <<EOF | sudo tee /etc/wireguard/wg0-client.conf
[Interface]
PrivateKey = $client_private_key
Address = 10.0.0.2/24

[Peer]
PublicKey = $server_public_key
AllowedIPs = 0.0.0.0/0
Endpoint = $(curl -s ifconfig.me):51820
EOF

# 启用IP转发
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 启动WireGuard服务
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0

# 完成
echo "WireGuard服务器和客户端已成功安装和配置！"

# 输出客户端配置文件内容
echo "以下是客户端配置文件内容："
cat /etc/wireguard/wg0-client.conf
