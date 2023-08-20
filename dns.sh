#!/bin/bash

Font_Black="\033[30m"
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Blue="\033[34m"
Font_Purple="\033[35m"
Font_SkyBlue="\033[36m"
Font_White="\033[37m"
Font_Suffix="\033[0m"

UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"

function MediaUnlockTest_Tiktok_Region() {
    echo -n -e " Tiktok Region:\t\t\c"
    local Ftmpresult=$(curl --user-agent "${UA_Browser}" -s --max-time 10 "https://www.tiktok.com/")

    if [[ "$Ftmpresult" = "curl"* ]]; then
        echo -n -e "\r Tiktok Region:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local FRegion=$(echo "$Ftmpresult" | grep -o '"region":"[^"]*' | sed 's/"region":"//')
    if [ -n "$FRegion" ]; then
        echo -n -e "\r Tiktok Region:\t\t${Font_Green}【${FRegion}】${Font_Suffix}\n"
        return
    fi

    local STmpresult=$(curl --user-agent "${UA_Browser}" -sL --max-time 10 "https://www.tiktok.com" | gunzip -c)
    local SRegion=$(echo "$STmpresult" | grep -o '"region":"[^"]*' | sed 's/"region":"//')
    if [ -n "$SRegion" ]; then
        echo -n -e "\r Tiktok Region:\t\t${Font_Yellow}【${SRegion}】(可能为IDC IP)${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Tiktok Region:\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function Heading() {
    local local_ipv4=$(curl -4 -s --max-time 10 api64.ipify.org)
    local local_ipv4_asterisk=$(awk -F"." '{print $1"."$2".*.*"}' <<<"${local_ipv4}")
    local local_isp4=$(curl -s -4 -A "$UA_Browser" --max-time 10 "https://api.ip.sb/geoip/${local_ipv4}" | grep organization | cut -f4 -d '"')

    echo -e " ${Font_SkyBlue}** 您的网络为: ${local_isp4} (${local_ipv4_asterisk})${Font_Suffix} "
    echo "******************************************"
    echo ""
}

function Goodbye() {
    echo ""
    echo "******************************************"
    echo ""
    echo -e ""
    echo -e ""
    echo -e ""
    echo -e ""
    echo -e ""
    echo -e ""
    echo -e ""
    echo -e "${Font_SkyBlue}【TikTok相关】${Font_Suffix}"
    echo -e "================================================"
    echo -e "${Font_Yellow}Residential IP TikTok解锁${Font_Suffix}"
    echo ""
    echo -e "${Font_Green}✅ ${Font_Suffix} ${Font_SkyBlue}各国家宽IP${Font_Suffix}"
    echo -e "${Font_Green}✅ ${Font_Suffix} ${Font_SkyBlue}一键配置${Font_Suffix}"
    echo -e "${Font_Green}✅ ${Font_Suffix} ${Font_SkyBlue}支持定制${Font_Suffix}"
    echo ""
    echo -e "${Font_Yellow}联系咨询: https://t.me/czgno${Font_Suffix}"
    echo -e "================================================"
    echo -e ""
    echo -e ""
    echo -e ""
    echo -e ""
}

function ScriptTitle() {
    echo -e "${Font_SkyBlue}【Tiktok区域检测】${Font_Suffix}"
    echo -e "${Font_Green}BUG反馈或使用交流可加TG群组${Font_Suffix} ${Font_Yellow}https://t.me/tiktok_operate ${Font_Suffix}"
    echo ""
    echo -e " ** 测试时间: $(date)"
    echo ""
}

clear
ScriptTitle
Heading
MediaUnlockTest_Tiktok_Region
Goodbye
