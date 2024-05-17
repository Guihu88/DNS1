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
timeout 30s tshark -i "$INTERFACE" -w "$CAPTURE_FILE"

# 分析捕获的流量，找到 TikTok 直播的上传IP和端口
echo "分析捕获的流量以查找上传流量..."
UPLOAD_IP=$(tshark -r "$CAPTURE_FILE" -Y "tcp.dstport == 1935" -T fields -e ip.dst | sort | uniq)
UPLOAD_PORT=$(tshark -r "$CAPTURE_FILE" -Y "tcp.dstport == 1935" -T fields -e tcp.dstport | sort | uniq)

# 检查是否找到了IP和端口
if [ -z "$UPLOAD_IP" ] || [ -z "$UPLOAD_PORT" ]; then
  echo "未找到TikTok直播上传流量，请确保在运行脚本时有进行直播"
  exit 1
fi

echo "找到上传流量：IP = $UPLOAD_IP, 端口 = $UPLOAD_PORT"

# 设置iptables规则阻止上传流量
echo "设置iptables规则以阻止上传流量..."
iptables -A OUTPUT -p tcp --dport "$UPLOAD_PORT" -d "$UPLOAD_IP" -j REJECT
iptables -A INPUT -p tcp --sport "$UPLOAD_PORT" -s "$UPLOAD_IP" -j REJECT

# 保存iptables规则
echo "保存iptables规则..."
netfilter-persistent save

echo "已成功阻止TikTok直播上传流量"

# 清理临时文件
rm "$CAPTURE_FILE"
