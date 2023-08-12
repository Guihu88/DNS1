#!/bin/bash

# 创建自定义DNS配置文件路径
custom_dns_path="/etc/custom_dns"
custom_dns_file="$custom_dns_path/custom_dns.conf"

# 创建自定义DNS配置文件
mkdir -p "$custom_dns_path"
echo "nameserver 8.8.8.8" > "$custom_dns_file"  # 默认的DNS服务器地址

# 自动获取国家代码
country_code=$(curl -s ipinfo.io/country)
case $country_code in
    TH)
        echo "nameserver 61.19.42.5" >> "$custom_dns_file"
        echo "nameserver 8.8.8.8" >> "$custom_dns_file"
        ;;
    PH)
        echo "nameserver 121.58.203.4" >> "$custom_dns_file"
        echo "nameserver 8.8.8.8" >> "$custom_dns_file"
        ;;
    MY)
        echo "nameserver 49.236.193.35" >> "$custom_dns_file"
        echo "nameserver 203.176.144.12" >> "$custom_dns_file"
        echo "nameserver 8.8.8.8" >> "$custom_dns_file"
        ;;
    ID)
        echo "nameserver 8.8.8.8" >> "$custom_dns_file"
        ;;
esac

# 自动适配操作系统并替换DNS配置文件路径
if [ -f "/etc/network/interfaces" ]; then
    config_file="/etc/network/interfaces"
elif [ -f "/etc/sysconfig/network-scripts/ifcfg-eth0" ]; then
    config_file="/etc/sysconfig/network-scripts/ifcfg-eth0"
elif [ -f "/etc/netplan/01-netcfg.yaml" ]; then
    config_file="/etc/netplan/01-netcfg.yaml"
else
    echo "无法找到适当的DNS配置文件路径。"
    exit 1
fi

# 备份原始配置文件
backup_file="${config_file}.bak"
cp "$config_file" "$backup_file"

# 替换dns-nameservers行
sed -i "/^ *dns-nameservers /c\dns-nameservers $custom_dns_file" "$config_file"

# 重启网络服务
if command -v systemctl >/dev/null 2>&1; then
    systemctl restart NetworkManager  # CentOS 使用 NetworkManager
else
    service networking restart  # Ubuntu 和 Debian 使用 networking
fi

# 检查网络连接
if ping -c 3 google.com >/dev/null 2>&1; then
    echo "DNS更换成功并且网络连接正常。"
else
    echo "无法重新启动网络服务或建立网络连接。请手动检查网络设置。"
fi
