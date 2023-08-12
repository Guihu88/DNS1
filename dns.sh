#!/bin/bash

# 备份原始配置文件
config_file="/etc/network/interfaces.d/50-cloud-init"
backup_file="${config_file}.bak"
cp "$config_file" "$backup_file"

# 新的DNS服务器地址根据国家
country_code=$(curl -s ipinfo.io/country)
case $country_code in
    TH)
        new_dns_servers="61.19.42.5 8.8.8.8"
        ;;
    PH)
        new_dns_servers="121.58.203.4 8.8.8.8"
        ;;
    MY)
        new_dns_servers="49.236.193.35 203.176.144.12 8.8.8.8"
        ;;
    ID)
        new_dns_servers="8.8.8.8"
        ;;
    *)
        new_dns_servers="默认的DNS服务器地址"
        ;;
esac

# 替换dns-nameservers行
sed -i "/^ *dns-nameservers /c\dns-nameservers $new_dns_servers" "$config_file"

# 重启网络服务
service networking restart

# 检查网络连接
if ping -c 3 google.com >/dev/null 2>&1; then
    echo "DNS更换成功并且网络连接正常。"
else
    echo "无法重新启动网络服务或建立网络连接。请手动检查网络设置。"
fi
