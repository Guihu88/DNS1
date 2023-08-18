#!/bin/bash

country=$(curl -s https://ipinfo.io/country)
echo "检测到的国家：$country"

case $country in
    "PH")
        dns_server="8.8.8.8"
        ;;
    "VN")
        dns_server="1.1.1.1"
        ;;
    "MY")
        dns_server="208.67.222.222"
        ;;
    "TH")
        dns_server="9.9.9.9"
        ;;
    *)
        echo "未识别的国家或不在列表中。"
        exit 1
        ;;
esac

echo "设置 DNS 服务器为 $dns_server"
echo "nameserver $dns_server" | sudo tee /etc/resolv.conf

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
