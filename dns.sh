#!/bin/bash

# 创建自定义DNS配置文件路径
custom_dns_path="/etc/custom_dns"
custom_dns_file="$custom_dns_path/custom_dns.conf"

# 创建自定义DNS配置文件
mkdir -p "$custom_dns_path"
echo "nameserver 8.8.8.8" > "$custom_dns_file"  # 默认的DNS服务器地址
echo "自定义DNS配置文件创建成功。"

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

# 配置网络接口使用自定义DNS服务器
nmcli con mod "Wired Connection 1" ipv4.dns "$custom_dns_file"
nmcli con up "Wired Connection 1"

echo "网络接口 'Wired Connection 1' 配置为使用自定义DNS服务器。"
