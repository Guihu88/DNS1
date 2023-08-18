#!/bin/bash

# 检测到的国家
country=$(curl -s https://ipinfo.io/country)

# 定义 DNS 服务器列表
declare -A dns_servers
dns_servers["PH"]="121.58.203.4 8.8.8.8"
dns_servers["VN"]="183.91.184.14 8.8.8.8"
dns_servers["MY"]="49.236.193.35 8.8.8.8"
dns_servers["TH"]="61.19.42.5 8.8.8.8"
dns_servers["ID"]="116.212.101.10 116.212.100.98"
dns_servers["TW"]="202.43.162.37 168.95.1.1"

# 设置 DNS 服务器函数
set_dns_servers() {
    echo "清空原有 DNS 设置"
    echo -n | sudo tee /etc/resolv.conf

    echo "设置 DNS 服务器"
    for dns_server in ${dns_servers[$country]}; do
        echo "nameserver $dns_server" | sudo tee -a /etc/resolv.conf
    done

    if [ $? -eq 0 ]; then
        echo "DNS 设置已成功更新。"
    else
        echo "更新 DNS 设置失败。"
        exit 1
    fi
}

# 禁用 NetworkManager 更新 resolv.conf
disable_networkmanager_dns_update() {
    echo -e "[main]\ndns=none" | sudo tee /etc/NetworkManager/NetworkManager.conf
    sudo systemctl restart NetworkManager
}

# 清除 DNS 缓存函数
flush_dns_cache() {
    sudo systemd-resolve --flush-caches
    if [ $? -eq 0 ]; then
        echo "清除 DNS 缓存成功。"
    else
        echo "清除 DNS 缓存失败。"
    fi
}

# 执行主函数
main() {
    echo "检测到的国家：$country"

    # 设置 DNS 服务器
    set_dns_servers

    # 禁用 NetworkManager 更新 resolv.conf
    disable_networkmanager_dns_update

    # 清除 DNS 缓存
    flush_dns_cache
}

# 执行主函数
main
