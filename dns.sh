#!/bin/bash

# 新的DNS服务器地址
new_dns_servers="61.19.42.5"

# 检查是否存在网络配置文件
network_config_file="/etc/sysconfig/network-scripts/ifcfg-eth0"  # 根据网络接口名称调整
if [ ! -f "$network_config_file" ]; then
    echo "Error: Network configuration file '$network_config_file' not found."
    exit 1
fi

# 备份原始配置文件
backup_file="${network_config_file}.bak"
cp "$network_config_file" "$backup_file"

# 更新DNS服务器地址
sed -i "/^ *DNS1=/c\DNS1=$new_dns_servers" "$network_config_file"

# 重启网络服务
if command -v systemctl &>/dev/null; then
    sudo systemctl restart network
else
    sudo service network restart
fi

# 等待一段时间，确保网络服务有足够的时间来启动
sleep 5

# 检查网络连接
ping -c 3 google.com >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "DNS更换成功并且网络连接正常。"
else
    echo "无法重新启动网络服务或建立网络连接。请手动检查网络设置。"
fi
