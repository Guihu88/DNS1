#!/bin/bash

# 自动检测网络管理工具
if command -v nmcli >/dev/null 2>&1; then
    network_manager="nmcli"
elif command -v networkctl >/dev/null 2>&1; then
    network_manager="networkctl"
else
    echo "无法确定网络管理工具。"
    exit 1
fi

# 自动获取适当的 DNS 配置文件路径
if [ "$network_manager" == "nmcli" ]; then
    config_file=$(nmcli -t -f NAME,TYPE connection show --active | grep ethernet | cut -d':' -f1)
elif [ "$network_manager" == "networkctl" ]; then
    config_file=$(networkctl list --lines=2 | tail -1 | awk '{print $1}')
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
if [ "$network_manager" == "nmcli" ]; then
    nmcli connection modify "$config_file" ipv4.dns "$new_dns_servers"
    nmcli connection down "$config_file" && nmcli connection up "$config_file"
elif [ "$network_manager" == "networkctl" ]; then
    sed -i "/^ *DNS=/c\DNS=$new_dns_servers" "/etc/systemd/network/$config_file.network"
    systemctl restart systemd-networkd
fi

# 检查网络连接
if ping -c 3 google.com >/dev/null 2>&1; then
    echo "DNS 更换成功并且网络连接正常。"
else
    echo "无法重新启动网络服务或建立网络连接。请手动检查网络设置。"
fi
