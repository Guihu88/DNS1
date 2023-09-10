#!/bin/bash

# 安装依赖软件
sudo yum install -y epel-release
sudo yum install -y python3-pip
pip3 install shadowsocks

# 配置Shadowsocks服务器
echo "{
  \"server\":\"0.0.0.0\",
  \"server_port\":8388,
  \"local_address\":\"127.0.0.1\",
  \"local_port\":1080,
  \"password\":\"YourPassword\",
  \"timeout\":300,
  \"method\":\"aes-256-cfb\"
}" > /etc/shadowsocks.json

# 启动Shadowsocks服务器
ssserver -c /etc/shadowsocks.json -d start

echo "Shadowsocks服务器已启动。配置信息如下："
echo "服务器地址：YourServerIP"
echo "服务器端口：8388"
echo "密码：YourPassword"
echo "加密方法：aes-256-cfb"
