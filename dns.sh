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

# 获取网络接口名称
interface=$(ip route | grep default | awk '{print $5}')

# 配置网络接口使用自定义DNS服务器
nmcli con mod "$interface" ipv4.dns "$custom_dns_file"
nmcli con up "$interface"

echo "网络接口 $interface 配置为使用自定义DNS服务器。"
