#!/bin/bash

country=$(curl -s https://ipinfo.io/country)
echo "检测到的国家：$country"

case $country in
    "PH")
        dns_servers=("121.58.203.4")
        ;;
    "VN")
        dns_servers=("183.91.184.14 8.8.8.8")
        ;;
    "MY")
        dns_servers=("49.236.193.35")
        ;;
    "TH")
        dns_servers=("61.19.42.5")
        ;;
    *)
        echo "未识别的国家或不在列表中。"
        exit 1
        ;;
esac

echo "设置 DNS 服务器为 ${dns_servers[@]}"
for dns_server in "${dns_servers[@]}"; do
    echo "nameserver $dns_server" | sudo tee -a /etc/resolv.conf
done

if [ $? -eq 0 ]; then
    echo "DNS 设置已成功更新。"
    
    echo "重新启动网络服务..."
    sudo service network-manager restart
    
    echo "清除 DNS 缓存..."
    sudo systemd-resolve --flush-caches
    
    echo "DNS 更改已生效。"
else
    echo "更新 DNS 设置失败。"
fi
