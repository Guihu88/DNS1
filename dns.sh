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
echo -n | tee /etc/resolv.conf

echo "设置 DNS 服务器"
for dns_server in "${dns_servers[@]}"; do
    echo "nameserver $dns_server" >> /etc/resolv.conf
done

if [ $? -eq 0 ]; then
    echo "DNS 设置已成功更新。"
    
    echo "重新启动网络服务..."
    service network-manager restart
    
    echo "清除 DNS 缓存..."
    systemd-resolve --flush-caches
    
    echo "DNS 更改已生效。"
    
    # 自动搭建 Shadowsocks
    echo "开始自动搭建 Shadowsocks"
    # 在这里添加自动搭建 Shadowsocks 的命令
    # 示例命令，需要替换为实际命令
    ss_port=$(shuf -i 10000-65535 -n 1)  # 生成随机端口
    ss_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)  # 生成随机密码
    ss_method="aes-256-gcm"
    
    # 写入 Shadowsocks 配置文件
    echo "{
    \"server\":\"$public_ip\",
    \"server_port\":$ss_port,
    \"password\":\"$ss_password\",
    \"method\":\"$ss_method\"
}" | tee /etc/shadowsocks/config.json
    
    if [ $? -eq 0 ]; then
        echo "Shadowsocks 已成功搭建。"
    else
        echo "搭建 Shadowsocks 失败。"
    fi
else
    echo "更新 DNS 设置失败。"
fi
