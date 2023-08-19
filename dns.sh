#!/bin/bash

# 检测到的国家
country=$(curl -s https://ipinfo.io/country)
log_file="/var/log/change_dns.log"  # 日志文件路径

# 设置日志输出
exec > >(tee -i $log_file)
exec 2>&1

# 输出检测到的国家
echo -e "\n\n检测到的国家：$country ✅"

# 定义 DNS 服务器
declare -A dns_servers
dns_servers=(
    # ... 添加其他国家的DNS服务器
)

# 获取 /etc/resolv.conf 路径
resolv_conf_path="/etc/resolv.conf"

# 修改 /etc/resolv.conf
update_resolv_conf() {
    echo -e "执行任务：修改 $resolv_conf_path"
    echo -e "# New DNS Servers" | sudo tee $resolv_conf_path.new
    for dns_server in ${dns_servers[$country]}; do
        echo "nameserver $dns_server" | sudo tee -a $resolv_conf_path.new
    done
    echo "执行命令：sudo mv $resolv_conf_path.new $resolv_conf_path"
    sudo mv $resolv_conf_path.new $resolv_conf_path
}

# 检查 /etc/resolv.conf 是否已更新为自定义的DNS
check_custom_dns() {
    local found_custom_dns=false
    while IFS= read -r line; do
        if [[ $line == "nameserver ${dns_servers[$country]}" ]]; then
            found_custom_dns=true
            break
        fi
    done < "$resolv_conf_path"
    
    $found_custom_dns
}

# 重启 NetworkManager
restart_network_manager() {
    echo "执行命令：sudo systemctl restart NetworkManager"
    sudo systemctl restart NetworkManager
}

# 执行方案二
execute_alternate_plan() {
    update_interfaces
    echo -e "任务失败，尝试方案二。"
    update_interfaces
}

# 方案二：修改 /etc/network/interfaces.d/50-cloud-init
update_interfaces() {
    if grep -q "dns-nameservers" /etc/network/interfaces.d/50-cloud-init; then
        sudo sed -i '/dns-nameservers/d' /etc/network/interfaces.d/50-cloud-init
        echo -e "修改 /etc/network/interfaces.d/50-cloud-init 成功。"
    else
        echo -e "未找到需要修改的文件。"
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
            if check_custom_dns; then
                execute_with_sudo "mv $resolv_conf_path.new $resolv_conf_path"
                restart_network_manager

                if [ $? -eq 0 ]; then
                    echo -e "修改DNS成功，已重启NetworkManager。"
                    echo -e "\n\n================================================\n"
                    echo -e "定制IPLC线路：广港、沪日、沪美、京德等"
                    echo -e "定制TIKTOK网络：美国、泰国、越南、菲律宾等"
                    echo -e "\n================================================\n\n"
                    echo -e "NDS已成功更换成目标国家：$country ✅\n\n"
                else
                    execute_alternate_plan
                fi
            else
                echo -e "修改DNS失败，未找到自定义DNS。"
            fi
            ;;
        *)
            echo -e "未识别的国家或不在列表中。"
            exit 1
            ;;
    esac
}

# 执行主函数
main
