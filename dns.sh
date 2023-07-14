#!/bin/bash

# 备份原始配置文件
config_file="/etc/network/interfaces.d/50-cloud-init"
backup_file="${config_file}.bak"
cp "$config_file" "$backup_file"

# 设置文件所有者和权限
chown root:root "$config_file"
chmod 644 "$config_file"

# 新的DNS服务器地址
new_dns_servers="61.19.42.5"

# 替换dns-nameservers行
if grep -q "dns-nameservers" "$config_file"; then
    sed -i "s/^dns-nameservers.*/dns-nameservers $new_dns_servers/" "$config_file"
else
    echo "dns-nameservers $new_dns_servers" >> "$config_file"
fi

# 重启网络服务
systemctl restart networking

# 检查网络连接
sleep 5  # 等待网络服务重新启动
ping -c 3 google.com >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Network configuration updated and network connection is successful."
else
    echo "Failed to restart network service or establish network connection. Please check your network settings manually."
fi
