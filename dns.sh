#!/bin/bash
shopt -s expand_aliases
Font_Black="\033[30m"
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Blue="\033[34m"
Font_Purple="\033[35m"
Font_SkyBlue="\033[36m"
Font_White="\033[37m"
Font_Suffix="\033[0m"

# ... （之前的变量和函数定义）

# 脚本开始
clear

# 检查操作系统
checkOS() {
    ifCentOS=$(cat /etc/os-release | grep CentOS)
    if [ -n "$ifCentOS" ]; then
        OS_Version=$(cat /etc/os-release | grep REDHAT_SUPPORT_PRODUCT_VERSION | cut -f2 -d'"')
        if [[ "$OS_Version" -lt "8" ]]; then
            echo -e "${Font_Red}此脚本不支持CentOS${OS_Version}，请升级至CentOS8或更换其他操作系统${Font_Suffix}"
            echo -e "${Font_Red}3秒后退出脚本...${Font_Suffix}"
            sleep 3
            exit 1
        fi
    fi
}
checkOS

# ... （之前的变量和函数定义）

# 脚本标题
function ScriptTitle() {
    echo -e "${Font_SkyBlue}【Tiktok区域检测】${Font_Suffix}"
    echo -e "${Font_Green}BUG反馈或使用交流可加TG群组${Font_Suffix} ${Font_Yellow}https://t.me/tiktok_operate ${Font_Suffix}"
    echo ""
    echo -e " ** 测试时间: $(date)"
    echo ""
}
ScriptTitle

# 运行脚本
function RunScript() {
    Heading
    MediaUnlockTest_Tiktok_Region
    Goodbye
}

RunScript
