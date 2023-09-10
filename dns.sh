#!/bin/bash

# 安装Shadowsocks依赖和Shadowsocks-libev
sudo yum install -y epel-release
sudo yum install -y shadowsocks-libev

# 生成随机密码
random_password=$(date +%s | sha256sum | base64 | head -c 12 ; echo)

# 配置Shadowsocks
cat <<EOF | sudo tee /etc/shadowsocks/config.json
{
  "server":"0.0.0.0",
  "server_port":8388,
  "password":"$random_password",
  "method":"aes-256-gcm",
  "timeout":300
}
EOF

# 启动Shadowsocks服务
sudo systemctl start shadowsocks-libev
sudo systemctl enable shadowsocks-libev

# 获取服务器IP地址
server_ip=$(curl -s ifconfig.me)

echo "Shadowsocks服务器已成功安装和配置！"
echo "服务器地址: $server_ip"
echo "服务器端口: 8388"
echo "密码: $random_password"
echo "加密方法: aes-256-gcm"
