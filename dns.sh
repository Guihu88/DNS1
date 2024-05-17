#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以root权限运行此脚本"
  exit 1
fi

# 设置捕获接口和文件路径
INTERFACE="eth0"
CAPTURE_FILE="/tmp/tiktok_live.pcap"
FILTER_FILE="/tmp/tiktok_filter.pcap"

# 捕获 TikTok 直播流量
echo "正在捕获流量，请在用户进行 TikTok 直播时运行此脚本..."
timeout 300s tshark -i "$INTERFACE" -w "$CAPTURE_FILE"

# 分析捕获的流量，找到 TikTok 直播的上传IP和端口
echo "分析捕获的流量以查找上传流量..."
tshark -r "$CAPTURE_FILE" -Y "ip.dst==157.240.0.0/16" -T fields -e ip.dst -e tcp.dstport | sort | uniq > /tmp/tiktok_uploads.txt

# 检查是否找到了IP和端口
if [ ! -s /tmp/tiktok_uploads.txt ]; then
  echo "未找到TikTok直播上传流量，请确保在运行脚本时有进行直播"
  exit 1
fi

# 读取找到的IP和端口，并设置iptables规则阻止上传流量
while IFS= read -r line; do
  UPLOAD_IP=$(echo "$line" | awk '{print $1}')
  UPLOAD_PORT=$(echo "$line" | awk '{print $2}')
  echo "找到上传流量：IP = $UPLOAD_IP, 端口 = $UPLOAD_PORT"
  iptables -A OUTPUT -p tcp --dport "$UPLOAD_PORT" -d "$UPLOAD_IP" -j REJECT
  iptables -A INPUT -p tcp --sport "$UPLOAD_PORT" -s "$UPLOAD_IP" -j REJECT
done < /tmp/tiktok_uploads.txt

# 保存iptables规则
echo "保存iptables规则..."
netfilter-persistent save

echo "已成功阻止TikTok直播上传流量"

# 清理临时文件
rm "$CAPTURE_FILE" /tmp/tiktok_uploads.txt
