#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以root权限运行此脚本"
  exit 1
fi

# 设置捕获接口和文件路径
INTERFACE="eth0"
CAPTURE_FILE="/tmp/capture_full.pcap"
ANALYSIS_FILE="/tmp/tiktok_analysis.txt"
UPLOADS_FILE="/tmp/tiktok_uploads.txt"

# 捕获 TikTok 直播流量
echo "正在捕获流量，请在用户进行 TikTok 直播时运行此脚本..."
timeout 600s tshark -i "$INTERFACE" -w "$CAPTURE_FILE"

# 分析捕获的流量，找到 TikTok 直播的上传IP和端口
echo "分析捕获的流量以查找上传流量..."
tshark -r "$CAPTURE_FILE" -T fields -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tls.handshake.extensions_server_name | grep "tiktok" > "$ANALYSIS_FILE"

# 筛选出上传流量的IP和端口
grep "tiktok" "$ANALYSIS_FILE" | awk '{print $1 " " $2 " " $3 " " $4}' | sort | uniq > "$UPLOADS_FILE"

# 检查是否找到了IP和端口
if [ ! -s "$UPLOADS_FILE" ]; then
  echo "未找到TikTok直播上传流量，请确保在运行脚本时有进行直播"
  exit 1
fi

# 读取找到的IP和端口，并设置iptables规则阻止上传流量
while IFS= read -r line; do
  SRC_IP=$(echo "$line" | awk '{print $1}')
  DST_IP=$(echo "$line" | awk '{print $2}')
  SRC_PORT=$(echo "$line" | awk '{print $3}')
  DST_PORT=$(echo "$line" | awk '{print $4}')
  
  # 阻止上传流量
  iptables -A OUTPUT -s "$SRC_IP" -d "$DST_IP" -p tcp --dport "$DST_PORT" -j DROP
  iptables -A OUTPUT -s "$SRC_IP" -d "$DST_IP" -p tcp --sport "$SRC_PORT" -j DROP
done < "$UPLOADS_FILE"

echo "已阻止所有检测到的TikTok直播上传流量。"
