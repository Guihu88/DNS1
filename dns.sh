#!/bin/bash

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
    "ID")
        dns_servers=("116.212.101.10" "116.212.100.98")
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
else
    echo "更新 DNS 设置失败。"
fi
