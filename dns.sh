#!/bin/bash

# 备份原始配置文件
config_file="/etc/network/interfaces.d/50-cloud-init"
backup_file="${config_file}.bak"
cp "$config_file" "$backup_file"

# 新的DNS服务器地址
new_dns_servers="180.232.77.210 124.6.165.168 202.78.97.41 203.115.130.7 210.4.2.61 122.2.65.202 124.106.223.151 210.5.92.6 115.147.21.134 203.127.225.10 124.6.147.164 203.177.133.235 121.58.203.4 203.160.162.216"

# 替换dns-nameservers行
sed -i "/^ *dns-nameservers /c\dns-nameservers $new_dns_servers" "$config_file"

# 重启网络服务
service networking restart

# 检查网络连接
ping -c 3 google.com >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "DNS更换成功并且网络连接正常。"
else
    echo "无法重新启动网络服务或建立网络连接。请手动检查网络设置。"
fi
