#!/bin/bash

# 获取 TikTok 返回的国家代码
TiktokRegion=$(curl -s https://www.tiktok.com/ | grep -oP '(?<="region":")[A-Z]+')

# 判断国家代码并输出对应国家
case $TiktokRegion in
    MY)
        echo "马来西亚 (Malaysia)"
        ;;
    PH)
        echo "菲律宾 (Philippines)"
        ;;
    *)
        echo "未知地区"
        ;;
esac
