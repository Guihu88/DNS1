#!/bin/bash

# 检测到的国家
country=$(curl -s https://ipinfo.io/country)
echo -e "\033[1;33m检测到的国家：$country\033[0m"

# 定义 DNS 服务器
declare -A dns_servers
dns_servers=(
    ["PH"]="121.58.203.4 8.8.8.8"
    ["VN"]="183.91.184.14 8.8.8.8"
    ["MY"]="49.236.193.35 8.8.8.8"
    ["TH"]="61.19.42.5 8.8.8.8"
    ["ID"]="202.146.128.3 202.146.128.7 202.146.131.12"
    ["TW"]="168.95.1.1 8.8.8.8"
    ["CN"]="111.202.100.123 101.95.120.109 101.95.120.106"
    ["HK"]="1.1.1.1 8.8.8.8"
    ["JP"]="133.242.1.1 133.242.1.2"
    ["US"]="1.1.1.1 8.8.8.8"
    ["DE"]="217.172.224.47 194.150.168.168"
)

# 方案一：修改 /etc/resolv.conf
update_resolv_conf() {
    echo "清空原有 DNS 设置"
    echo -n | sudo tee /etc/resolv.conf

    echo "设置 DNS 服务器"
    for dns_server in ${dns_servers[$country]}; do
        echo "nameserver $dns_server" | sudo tee -a /etc/resolv.conf
    done
}

# 方案二：修改 /etc/network/interfaces.d/50-cloud-init
update_interfaces() {
    if grep -q "dns-nameservers" /etc/network/interfaces.d/50-cloud-init; then
        sudo sed -i '/dns-nameservers/d' /etc/network/interfaces.d/50-cloud-init
        echo -e "\033[1;32m修改 /etc/network/interfaces.d/50-cloud-init 成功。\033[0m"
    else
        echo -e "\033[1;31m修改 /etc/network/interfaces.d/50-cloud-init 失败。\033[0m"
    fi
}

# 清除 DNS 缓存函数
flush_dns_cache() {
    echo "清除 DNS 缓存..."
    sudo systemd-resolve --flush-caches
    if [ $? -eq 0 ]; then
        echo -e "\033[1;32mDNS 缓存已清除。\033[0m"
    else
        echo -e "\033[1;31m清除 DNS 缓存失败。\033[0m"
    fi
}

# 主函数
main() {
    case $country in
        "PH"|"VN"|"MY"|"TH"|"ID"|"TW"|"CN"|"HK"|"JP"|"US"|"DE")
            update_resolv_conf
            flush_dns_cache
            ;;
        *)
            echo -e "\033[1;31m未识别的国家或不在列表中。\033[0m"
            exit 1
            ;;
    esac

    # 如果方案一更新失败，执行方案二
    if [ $? -ne 0 ]; then
        update_interfaces
    fi

    # 检查是否有成功的更新
    if [ $? -eq 0 ]; then
        echo -e "\033[1;32m更新 DNS 成功。\033[0m"
    else
        echo -e "\033[1;31m任务失败。\033[0m"
    fi

    echo -e "\033[1;33m定制IPLC线路：\033[1;32m广港、沪日、沪美、京德\033[0m"
    echo -e "\033[1;33m定制TIKTOK网络：\033[1;32m美国、泰国、越南、菲律宾等\033[0m"
    echo -e "\033[1;31m如有问题，请联系我：\033[1;33m联系方式TG:rocloudcc\033[0m"
    echo -e "\033[1;32m检测完成。\033[0m"
}

# 执行主函数
main
