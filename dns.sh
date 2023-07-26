#!/bin/bash

# 新的配置文件路径和名称
config_file="/etc/network/interfaces.d/50-cloud-init"
new_dns_servers="61.19.42.5"

# 检查配置文件是否存在
if [ ! -f "$config_file" ]; then
    # 如果文件不存在，创建新的配置文件并添加内容
    echo "dns-nameservers $new_dns_servers" | sudo tee "$config_file" >/dev/null
else
    # 备份原始配置文件
    backup_file="${config_file}.bak"
    sudo cp "$config_file" "$backup_file"
    
    # 替换dns-nameservers行
    if grep -q "^ *dns-nameservers" "$config_file"; then
        sudo sed -i "/^ *dns-nameservers/c\dns-nameservers $new_dns_servers" "$config_file"
    else
        echo "dns-nameservers $new_dns_servers" | sudo tee -a "$config_file" >/dev/null
    fi
fi

# 重启网络服务
if command -v systemctl &>/dev/null; then
    sudo systemctl restart networking
else
    sudo service networking restart
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
