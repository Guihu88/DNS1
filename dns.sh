#!/bin/bash

# 新的DNS服务器地址
new_dns_servers="61.19.42.5 8.8.8.8"

# 获取当前活动连接名
connection_name=$(nmcli connection show --active | grep -o '^[[:space:]]*[^[:space:]]*')

# 设置新的DNS服务器地址
sudo nmcli connection modify "$connection_name" ipv4.dns "$new_dns_servers"

# 重启NetworkManager
sudo systemctl restart NetworkManager

# 等待一段时间，确保NetworkManager有足够的时间来应用更改
sleep 5

# 检查网络连接
ping -c 3 google.com >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "DNS更换成功并且网络连接正常。"
else
    echo "无法重新启动NetworkManager或建立网络连接。请手动检查网络设置。"
fi
