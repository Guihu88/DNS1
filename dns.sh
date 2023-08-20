#!/bin/bash

# 使用curl获取TikTok页面内容
tiktok_response=$(curl -s "https://www.tiktok.com/")

# 提取国家代码（假设国家代码位于"region"字段中）
country_code=$(echo "$tiktok_response" | grep -o -P '(?<="region": ")[A-Z]+')

# 根据国家代码给出相应的归属地信息
case $country_code in
    MY)
        echo "马来西亚"
        ;;
    SG)
        echo "新加坡"
        ;;
    PH)
        echo "菲律宾"
        ;;
    # 添加其他国家代码和相应的归属地信息
    *)
        echo "未知归属地"
        ;;
esac
