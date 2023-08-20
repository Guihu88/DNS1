#!/bin/bash

function MediaUnlockTest_Tiktok_Region() {
    echo -n -e " Tiktok Region:\t\t\c"
    local Ftmpresult=$(curl $useNIC --user-agent "${UA_Browser}" -s --max-time 10 "https://www.tiktok.com/")

    if [[ "$Ftmpresult" = "curl"* ]]; then
        echo -n -e "\r Tiktok Region:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local FRegion=$(echo $Ftmpresult | grep '"region":' | sed 's/.*"region"//' | cut -f2 -d'"')
    if [ -n "$FRegion" ]; then
        echo -n -e "\r Tiktok Region:\t\t${Font_Green}【${FRegion}】${Font_Suffix}\n"
        return
    fi

    local STmpresult=$(curl $useNIC --user-agent "${UA_Browser}" -sL --max-time 10 -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" -H "Accept-Encoding: gzip" -H "Accept-Language: en" "https://www.tiktok.com" | gunzip 2>/dev/null)
    local SRegion=$(echo $STmpresult | grep '"region":' | sed 's/.*"region"//' | cut -f2 -d'"')
    if [ -n "$SRegion" ]; then
        echo -n -e "\r Tiktok Region:\t\t${Font_Yellow}【${SRegion}】(可能为IDC IP)${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Tiktok Region:\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function Heading() {
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

clear

function ScriptTitle() {
    echo -e "${Font_SkyBlue}【Tiktok区域检测】${Font_Suffix}"
    echo -e "${Font_Green}BUG反馈或使用交流可加TG群组${Font_Suffix} ${Font_Yellow}https://t.me/tiktok_operate ${Font_Suffix}"
    echo ""
    echo -e " ** 测试时间: $(date)"
    echo ""
}
ScriptTitle

function RunScript() {
    Heading
    MediaUnlockTest_Tiktok_Region
    Goodbye
}

RunScript
