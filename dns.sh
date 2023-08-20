#!/bin/bash

# 设置字体颜色
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Suffix="\033[0m"

# 获取IP地址
local_ipv4=$(curl -4 -s --max-time 10 api64.ipify.org)

# 发送请求获取TikTok页面内容
tiktok_page=$(curl -s --max-time 10 "https://www.tiktok.com/")

# 从页面内容中提取区域信息
region=$(echo $tiktok_page | grep -o '"region":"[^"]*' | sed 's/"region":"//')

# 判断是否成功获取区域信息
if [ -n "$region" ]; then
    echo -e " Tiktok Region:\t\t${Font_Green}【${region}】${Font_Suffix}"
else
    echo -e " Tiktok Region:\t\t${Font_Red}Failed${Font_Suffix}"
fi
