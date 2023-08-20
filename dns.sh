#!/bin/bash
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Red="\033[31m"
Font_Suffix="\033[0m"

function MediaUnlockTest_Tiktok_Region() {
    echo -n -e " Tiktok Region:\t\t\c"
    local Ftmpresult=$(curl -s --max-time 10 "https://www.tiktok.com/")

    if [[ "$Ftmpresult" = "curl"* ]]; then
        echo -n -e "\r Tiktok Region:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi

    local FRegion=$(echo $Ftmpresult | grep '"region":' | sed 's/.*"region"//' | cut -f2 -d'"')
    if [ -n "$FRegion" ]; then
        echo -n -e "\r Tiktok Region:\t\t${Font_Green}【${FRegion}】${Font_Suffix}\n"
        return
    fi

    local STmpresult=$(curl -sL --max-time 10 "https://www.tiktok.com" | gunzip 2>/dev/null)
    local SRegion=$(echo $STmpresult | grep '"region":' | sed 's/.*"region"//' | cut -f2 -d'"')
    if [ -n "$SRegion" ]; then
        echo -n -e "\r Tiktok Region:\t\t${Font_Yellow}【${SRegion}】(可能为IDC IP)${Font_Suffix}\n"
        return
    else
        echo -n -e "\r Tiktok Region:\t\t${Font_Red}Failed${Font_Suffix}\n"
        return
    fi
}

function RunScript() {
    MediaUnlockTest_Tiktok_Region
}

RunScript
