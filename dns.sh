#!/bin/bash

# 检查权限
if [[ $(id -u) -ne 0 ]]; then
    echo -e "\033[1;31m需要使用 root 权限运行此脚本\033[0m"
    exit 1
fi

# 检测到的操作系统类型
os_type=$(uname -s)

# 配置文件路径数组，根据不同的操作系统类型和发行版添加适当的路径
declare -A config_file_paths
config_file_paths=(
    ["Linux"]="/etc/resolv.conf"
    # 添加其他操作系统类型的路径
)

# 检测到的国家
country=$(curl -s https://ipinfo.io/country)
echo -e "\033[1;33m检测到的国家：\033[1;31m$country\033[0m" ✅

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

update_resolv_conf() {
    echo -e "\033[1;34m执行任务\033[0m"

    # 备份配置文件
    sudo cp "${config_file_paths[$os_type]}" "${config_file_paths[$os_type]}.bak"

    # 清除配置文件内容
    sudo sh -c "echo > ${config_file_paths[$os_type]}"

    # 添加新的 DNS 服务器
    for dns_server in ${dns_servers[$country]}; do
        echo -e "\033[1;34mnameserver \033[1;32m $dns_server\033[0m" | sudo tee -a "${config_file_paths[$os_type]}"
    done

    # 清除系统 DNS 缓存
    flush_dns_cache
}

flush_dns_cache() {
    sudo systemd-resolve --flush-caches 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "\033[1;32m清除 DNS 缓存成功。\033[0m"
    fi
    echo -e ""
}

main() {
    # 检查操作系统类型是否支持
    if [[ -z "${config_file_paths[$os_type]}" ]]; then
        echo -e "\033[1;31m不支持的操作系统类型。\033[0m"
        exit 1
    fi

    case $country in
        "PH"|"VN"|"MY"|"TH"|"ID"|"TW"|"CN"|"HK"|"JP"|"US"|"DE")
            update_resolv_conf
            ;;
        *)
            echo -e "\033[1;31m未识别的国家或不在列表中。\033[0m"
            exit 1
            ;;
    esac

    echo -e ""
    echo -e "================================================"
    echo -e ""
    echo -e "\033[3;33m定制IPLC线路：\033[1;32m广港、沪日、沪美、京德\033[0m"
    echo -e "\033[3;33mTG群聊：\033[1;31mhttps://t.me/rocloudiplc\033[0m"
    echo -e "\033[3;33m定制TIKTOK网络：\033[1;32m美国、泰国、越南、菲律宾等\033[0m"
    echo -e "\033[1;33m如有问题，请联系我：\033[1;35m联系方式TG：rocloudcc\033[0m"
    echo -e ""
    echo -e "================================================"
    echo -e ""
    echo -e ""
    echo -e "\033[1;32mNDS已成功更换成目标国家：\033[1;31m$country\033[0m" ✅
    echo -e ""
    echo -e ""
}

main
