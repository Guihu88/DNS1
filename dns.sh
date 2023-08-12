#!/bin/bash

# 备份原始配置文件
config_file=""
backup_file=""

# 获取系统发行版
if grep -qi "centos" /etc/os-release; then
    # CentOS
    config_file="/etc/sysconfig/network-scripts/ifcfg-eth0"  # 替换为适当的网络接口
    backup_file="${config_file}.bak"
elif grep -qi "ubuntu" /etc/os-release; then
    # Ubuntu
    config_file="/etc/netplan/01-netcfg.yaml"  # 根据Ubuntu的网络配置文件路径进行调整
    backup_file="${config_file}.bak"
fi

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

echo "正在更换DNS服务器为: $new_dns_servers"

# 替换dns-nameservers行
echo "替换前的 $config_file："
cat "$config_file"
sed -i "/^ *dns-nameservers /c\dns-nameservers $new_dns_servers" "$config_file"
echo "替换后的 $config_file："
cat "$config_file"

echo "重启网络服务..."

# 重启网络服务
if command -v systemctl >/dev/null 2>&1; then
    systemctl restart NetworkManager  # CentOS 使用 NetworkManager
else
    service networking restart  # Ubuntu 使用 networking
fi

echo "等待网络连接..."

# 检查网络连接
if ping -c 3 google.com >/dev/null 2>&1; then
    echo "DNS更换成功并且网络连接正常。"
else
    echo "无法重新启动网络服务或建立网络连接。请手动检查网络设置。"
fi
