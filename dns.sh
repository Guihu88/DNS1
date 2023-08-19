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
    # ... 添加其他国家的DNS服务器
)

# 修改 /etc/resolv.conf
update_resolv_conf() {
    echo -e "\033[1;34m执行任务：修改 /etc/resolv.conf\033[0m"
    for dns_server in ${dns_servers[$country]}; do
        echo "nameserver $dns_server" | su -c "tee /etc/resolv.conf.new"
    done
    echo "执行命令：mv /etc/resolv.conf.new /etc/resolv.conf"
    su -c "mv /etc/resolv.conf.new /etc/resolv.conf"
}

# 重启 NetworkManager
restart_network_manager() {
    echo "执行命令：systemctl restart NetworkManager"
    su -c "systemctl restart NetworkManager"
}

# 执行需要sudo权限的命令
execute_with_sudo() {
    if [ -f /etc/sudoers ]; then
        su -c "echo <your_sudo_password> | sudo -S $1"
    else
        su -c "$1"
    fi
}

# 主函数
main() {
    case $country in
        "PH"|"VN"|"MY"|"TH"|"ID"|"TW"|"CN"|"HK"|"JP"|"US"|"DE")
            update_resolv_conf
            execute_with_sudo "mv /etc/resolv.conf.new /etc/resolv.conf"
            restart_network_manager

            if [ $? -eq 0 ]; then
                echo -e "\033[1;32m修改DNS成功，已重启NetworkManager。\033[0m"
                echo -e "\n\n================================================\n"
                echo -e "\033[3;33m定制IPLC线路：\033[1;32m广港、沪日、沪美、京德等\033[0m"
                echo -e "\033[3;33m定制TIKTOK网络：\033[1;32m美国、泰国、越南、菲律宾等\033[0m"
                echo -e "\n================================================\n\n"
                echo -e "\033[1;32mNDS已成功更换成目标国家：\033[1;31m$country\033[0m ✅\n\n"
            else
                echo -e "\033[1;31m任务失败，尝试方案二。\033[0m"
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
