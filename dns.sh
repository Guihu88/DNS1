#!/bin/bash

function MediaUnlockTest_Tiktok_Region() {
    local Ftmpresult=$(curl -s --max-time 10 "https://www.tiktok.com/")

    if [[ "$Ftmpresult" = "curl"* ]]; then
        echo "Failed (Network Connection)"
        return
    fi

    local FRegion=$(echo $Ftmpresult | grep '"region":' | sed 's/.*"region"//' | cut -f2 -d'"')
    if [ -n "$FRegion" ]; then
        echo "【${FRegion}】"
        return
    fi

    local STmpresult=$(curl -sL --max-time 10 -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" -H "Accept-Encoding: gzip" -H "Accept-Language: en" "https://www.tiktok.com" | gunzip 2>/dev/null)
    local SRegion=$(echo $STmpresult | grep '"region":' | sed 's/.*"region"//' | cut -f2 -d'"')
    if [ -n "$SRegion" ]; then
        echo "【${SRegion}】(可能为IDC IP)"
        return
    else
        echo "Failed"
        return
    fi
}

MediaUnlockTest_Tiktok_Region
