#!/bin/bash

# 自动获取适当的 DNS 配置文件路径
dns_config_files=("/etc/resolv.conf" "/etc/network/interfaces" "/etc/sysconfig/network-scripts/ifcfg-eth0" "/etc/netplan/01-netcfg.yaml")

found_config_file=""
for file in "${dns_config_files[@]}"; do
    if [ -f "$file" ]; then
        found_config_file="$file"
        break
    fi
done

if [ -z "$found_config_file" ]; then
    echo "找不到适当的 DNS 配置文件。"
    exit 1
fi

# 自动获取国家代码
country_code=$(curl -s ipinfo.io/country)

# 自动选择适当的 DNS 服务器
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

# 更新 DNS 配置
echo "正在更换 DNS 服务器为: $new_dns_servers"
sed -i "/^ *nameserver /c\nameserver $new_dns_servers" "$found_config_file"

# 重启网络服务
if command -v systemctl >/dev/null 2>&1; then
    systemctl restart NetworkManager  # CentOS 使用 NetworkManager
else
    service networking restart  # Ubuntu 使用 networking
fi

# 检查网络连接
if ping -c 3 google.com >/dev/null 2>&1; then
    echo "DNS 更换成功并且网络连接正常。"
else
    echo "无法重新启动网络服务或建立网络连接。请手动检查网络设置。"
fi
