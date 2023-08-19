#!/bin/bash

# 检测到的国家
country=$(curl -s https://ipinfo.io/country)
log_file="/var/log/change_dns.log"  # 日志文件路径

# 设置日志输出
exec > >(tee -i $log_file)
exec 2>&1

# 输出检测到的国家
echo -e "\n\n\033[1;33m检测到的国家：\033[1;31m$country\033[0m ✅"

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
    # ... 添加其他国家的DNS服务器
)

# 获取 /etc/resolv.conf 路径
resolv_conf_path="/etc/resolv.conf"

# 修改 /etc/resolv.conf
update_resolv_conf() {
    echo -e "\033[1;34m执行任务：修改 $resolv_conf_path\033[0m"
    for dns_server in ${dns_servers[$country]}; do
        echo "nameserver $dns_server" | sudo tee $resolv_conf_path.new
    done
    echo "执行命令：sudo mv $resolv_conf_path.new $resolv_conf_path"
    sudo mv $resolv_conf_path.new $resolv_conf_path
}

# 重启 NetworkManager
restart_network_manager() {
    echo "执行命令：sudo systemctl restart NetworkManager"
    sudo systemctl restart NetworkManager
}

# 执行方案二
execute_alternate_plan() {
    update_interfaces
    echo -e "\033[1;31m任务失败，尝试方案二。\033[0m"
    echo -e ""
}

# 方案二：修改 /etc/network/interfaces.d/50-cloud-init
update_interfaces() {
    if grep -q "dns-nameservers" /etc/network/interfaces.d/50-cloud-init; then
        sudo sed -i '/dns-nameservers/d' /etc/network/interfaces.d/50-cloud-init
        echo -e "\033[1;32m修改 /etc/network/interfaces.d/50-cloud-init 成功。\033[0m"
    fi
}

# 执行需要sudo权限的命令
execute_with_sudo() {
    if [ -f /etc/sudoers ]; then
        sudo -S $1 <<< "your_sudo_password_here"
    else
        $1
    fi
}

# 主函数
main() {
    case $country in
        "PH"|"VN"|"MY"|"TH"|"ID"|"TW"|"CN"|"HK"|"JP"|"US"|"DE")
            update_resolv_conf
            execute_with_sudo "mv $resolv_conf_path.new $resolv_conf_path"
            restart_network_manager

            if [ $? -eq 0 ]; then
                echo -e "\033[1;32m修改DNS成功，已重启NetworkManager。\033[0m"
                echo -e "\n\n================================================\n"
                echo -e "\033[3;33m定制IPLC线路：\033[1;32m广港、沪日、沪美、京德等\033[0m"
                echo -e "\033[3;33m定制TIKTOK网络：\033[1;32m美国、泰国、越南、菲律宾等\033[0m"
                echo -e "\n================================================\n\n"
                echo -e "\033[1;32mNDS已成功更换成目标国家：\033[1;31m$country\033[0m ✅\n\n"
            else
                execute_alternate_plan
            fi
            ;;
        *)
            echo -e "\033[1;31m未识别的国家或不在列表中。\033[0m"
            exit 1
            ;;
    esac
}

# 执行主函数
main
