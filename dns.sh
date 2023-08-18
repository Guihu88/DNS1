#!/bin/bash

# 获取本机的公共 IP 地址
public_ip=$(curl -s https://api64.ipify.org)

country=$(curl -s https://ipinfo.io/country)
echo "检测到的国家：$country"

case $country in
    "PH")
        dns_servers=("121.58.203.4" "8.8.8.8")
        ;;
    "VN")
        dns_servers=("183.91.184.14" "8.8.8.8")
        ;;
    "MY")
        dns_servers=("49.236.193.35" "8.8.8.8")
        ;;
    "TH")
        dns_servers=("61.19.42.5" "8.8.8.8")
        ;;
    *)
        echo "未识别的国家或不在列表中。"
        exit 1
        ;;
esac

echo "清空原有 DNS 设置"
echo -n | sudo tee /etc/resolv.conf

echo "设置 DNS 服务器"
for dns_server in "${dns_servers[@]}"; do
    echo "nameserver $dns_server" | sudo tee -a /etc/resolv.conf
done

if [ $? -ne 0 ]; then
    echo "更新 DNS 设置失败。"
    exit 1
fi

echo "DNS 设置已成功更新。"

echo "重新启动网络服务..."
sudo systemctl restart NetworkManager

if [ $? -ne 0 ]; then
    echo "重新启动网络服务失败。"
    exit 1
fi

echo "网络服务已重新启动。"

echo "清除 DNS 缓存..."
sudo systemd-resolve --flush-caches

if [ $? -ne 0 ]; then
    echo "清除 DNS 缓存失败。"
    exit 1
fi

echo "DNS 缓存已清除。"

# 自动搭建 Shadowsocks
echo "开始自动搭建 Shadowsocks"

ss_port=$(shuf -i 10000-65535 -n 1)  # 生成随机端口
ss_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)  # 生成随机密码
ss_method="aes-256-gcm"

# 写入 Shadowsocks 配置文件
echo "{
    \"server\":\"$public_ip\",
    \"server_port\":$ss_port,
    \"password\":\"$ss_password\",
    \"method\":\"$ss_method\"
}" | sudo tee /etc/shadowsocks/config.json

if [ $? -ne 0 ]; then
    echo "写入 Shadowsocks 配置文件失败。"
    exit 1
fi

echo "Shadowsocks 配置文件已写入。"

# 启动 Shadowsocks
sudo systemctl start shadowsocks-libev

if [ $? -ne 0 ]; then
    echo "启动 Shadowsocks 失败。"
    exit 1
fi

echo "Shadowsocks 已成功搭建并启动。"

echo "完成。"
