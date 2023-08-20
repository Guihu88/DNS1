#!/bin/bash

# 定义TikTok网站URL
tiktok_url="https://www.tiktok.com/"

# 使用curl模拟浏览器请求获取TikTok网站内容
tiktok_data=$(curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36" "$tiktok_url")

# 从返回的内容中提取region信息
region=$(echo "$tiktok_data" | grep -o '"region":"[^"]*' | sed 's/"region":"//')

# 输出归属地信息
if [ -n "$region" ]; then
    echo "TikTok IP归属地：$region"
else
    echo "无法获取TikTok IP归属地信息。"
fi
