#!/bin/bash

# 检测到的国家
country=$(curl -s https://ipinfo.io/country)
echo "检测到的国家：$country"

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
        echo "DNS 设置已成功更新。"
    else
        echo "更新 DNS 设置失败。"
        # 尝试修改 /etc/network/interfaces.d/50-cloud-init
        if grep -q "dns-nameservers" /etc/network/interfaces.d/50-cloud-init; then
            sudo sed -i '/dns-nameservers/d' /etc/network/interfaces.d/50-cloud-init
            echo "修改 /etc/network/interfaces.d/50-cloud-init 成功。"
        else
            echo "修改 /etc/network/interfaces.d/50-cloud-init 失败。"
        fi
    fi
}

# 清除 DNS 缓存函数
flush_dns_cache() {
    echo "清除 DNS 缓存..."
    sudo systemd-resolve --flush-caches
    if [ $? -eq 0 ]; then
        echo "DNS 缓存已清除。"
    else
        echo "清除 DNS 缓存失败。"
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
            echo "未识别的国家或不在列表中。"
            exit 1
            ;;
    esac

    echo -e "\033[1;33m定制IPLC线路：广港、沪日、沪美、京德\033[0m"
    echo -e "\033[1;33m定制TIKTOK网络：美国、泰国、越南、菲律宾等\033[0m"
    echo -e "\033[1;31m如有问题，请联系我：联系方式TG:rocloudcc\033[0m"
    echo -e "\033[1;32m检测完成。\033[0m"
}

# 执行主函数
main
