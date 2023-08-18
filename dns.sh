#!/bin/bash

# 检测到的国家
country=$(curl -s https://ipinfo.io/country)
echo -e "\e[1;33m检测到的国家：$country\e[0m"

# 定义 DNS 服务器
declare -A dns_servers
dns_servers=(
    ["PH"]="\e[32m121.58.203.4 8.8.8.8\e[0m"
    ["VN"]="\e[32m183.91.184.14 8.8.8.8\e[0m"
    ["MY"]="\e[32m49.236.193.35 8.8.8.8\e[0m"
    ["TH"]="\e[32m61.19.42.5 8.8.8.8\e[0m"
    ["ID"]="\e[32m202.146.128.3 202.146.128.7 202.146.131.12\e[0m"
    ["TW"]="\e[32m168.95.1.1 8.8.8.8\e[0m"
    ["CN"]="\e[32m111.202.100.123 101.95.120.109 101.95.120.106\e[0m"
    ["HK"]="\e[32m1.1.1.1 8.8.8.8\e[0m"
    ["JP"]="\e[32m133.242.1.1 133.242.1.2\e[0m"
    ["US"]="\e[32m1.1.1.1 8.8.8.8\e[0m"
    ["DE"]="\e[32m217.172.224.47 194.150.168.168\e[0m"
)

# 获取本机的公共 IP 地址
public_ip=$(curl -s https://api64.ipify.org)

# 设置 DNS 服务器函数
set_dns_servers() {
    echo "清空原有 DNS 设置"
    echo -n | sudo tee /etc/resolv.conf

    echo "设置 DNS 服务器"
    for dns_server in ${dns_servers[$country]}; do
        echo "nameserver $dns_server" | sudo tee -a /etc/resolv.conf
    done

    if [ $? -eq 0 ]; then
        echo -e "\e[32mDNS 设置已成功更新。\e[0m"
    else
        echo -e "\e[31m更新 DNS 设置失败。\e[0m"
    fi
}

# 清除 DNS 缓存函数
flush_dns_cache() {
    echo "清除 DNS 缓存..."
    sudo systemd-resolve --flush-caches
    if [ $? -eq 0 ]; then
        echo -e "\e[32mDNS 缓存已清除。\e[0m"
    else
        echo -e "\e[31m清除 DNS 缓存失败。\e[0m"
    fi
}

# 主函数
main() {
    case $country in
        "PH"|"VN"|"MY"|"TH"|"ID"|"TW"|"CN"|"HK"|"JP"|"US"|"DE")
            set_dns_servers
            flush_dns_cache
            ;;
        *)
            echo -e "\e[31m未识别的国家或不在列表中。\e[0m"
            exit 1
            ;;
    esac

    echo -e "\e[1;33m定制IPLC线路：\e[0m\e[32m广港、沪日、沪美、京德\e[0m"
    echo -e "\e[1;33m定制TIKTOK网络：\e[0m\e[32m美国、泰国、越南、菲律宾等\e[0m"
    echo -e "\e[1;31m如有问题，请联系我：\e[0m\e[1;33m联系方式TG:rocloudcc\e[0m"
    echo -e "\e[32m检测完成。\e[0m"
}

# 执行主函数
main
