#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以root权限运行此脚本"
  exit 1
fi

# 设置捕获接口和文件路径
INTERFACE="eth0"
CAPTURE_FILE="/tmp/capture_full.pcap"
UPLOADS_FILE="/tmp/tiktok_uploads.txt"
BLOCKED_LOG="/tmp/blocked_tiktok_uploads.log"

# 捕获 TikTok 直播流量
echo "正在捕获流量，请在用户进行 TikTok 直播时运行此脚本..."
timeout 300s tshark -i "$INTERFACE" -w "$CAPTURE_FILE"

# 分析捕获的流量，找到 TikTok 直播的上传IP和端口
echo "分析捕获的流量以查找上传流量..."
tshark -r "$CAPTURE_FILE" -Y 'ip.dst == 152.32.148.67 || ip.src == 152.32.148.67' -T fields -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tls.handshake.extensions_server_name | grep "tiktok" > "$UPLOADS_FILE"

# 检查是否找到相关流量
if [ ! -s "$UPLOADS_FILE" ]; then
  echo "未检测到 TikTok 直播的上传流量。"
  exit 0
fi

# 解析出需要阻止的IP和端口，并记录到日志文件
echo "解析并阻止检测到的 TikTok 直播上传流量..."
echo "阻止的 TikTok 上传流量：" > "$BLOCKED_LOG"
while IFS= read -r line; do
  SRC_IP=$(echo $line | awk '{print $1}')
  DST_IP=$(echo $line | awk '{print $2}')
  SRC_PORT=$(echo $line | awk '{print $3}')
  DST_PORT=$(echo $line | awk '{print $4}')
  
  # 添加iptables规则来阻止流量
  iptables -A OUTPUT -p tcp -s "$SRC_IP" --sport "$SRC_PORT" -d "$DST_IP" --dport "$DST_PORT" -j DROP
  iptables -A OUTPUT -p tcp -s "$DST_IP" --sport "$DST_PORT" -d "$SRC_IP" --dport "$SRC_PORT" -j DROP

  echo "$SRC_IP:$SRC_PORT -> $DST_IP:$DST_PORT" >> "$BLOCKED_LOG"
  echo "已阻止流量：$SRC_IP:$SRC_PORT -> $DST_IP:$DST_PORT"
done < "$UPLOADS_FILE"

# 保存iptables规则
iptables-save > /etc/iptables/rules.v4

echo "TikTok 直播的上传流量已被阻止。所有被阻止的流量记录在 $BLOCKED_LOG 中。"
