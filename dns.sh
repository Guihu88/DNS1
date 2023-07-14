#!/bin/bash

# 备份原始配置文件
config_file="/etc/network/interfaces.d/50-cloud-init"
backup_file="${config_file}.bak"
cp "$config_file" "$backup_file"

# 新的DNS服务器地址
new_dns_servers="61.19.42.5"

# 替换dns-nameservers行
sed -i "/^dns-nameservers/c\dns-nameservers $new_dns_servers" "$config_file"

# 重启网络服务
network_service=$(systemctl list-units --type=service --state=running | grep -E 'networking.service|NetworkManager.service' | awk '{print $1}')
if [[ -n "$network_service" ]]; then
    systemctl restart "$network_service"
else
    echo "Failed to find running network service. Please restart the network manually."
fi
