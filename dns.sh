#!/bin/bash

# 更改yum镜像源为阿里云镜像源（适用于CentOS）
sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf
sed -i 's/#baseurl/baseurl/' /etc/yum.repos.d/CentOS-Base.repo
sed -i 's/mirrorlist/#mirrorlist/' /etc/yum.repos.d/CentOS-Base.repo
echo "baseurl=http://mirrors.aliyun.com/centos/7/os/x86_64/" >> /etc/yum.repos.d/CentOS-Base.repo

# 安装必要的依赖
yum install -y epel-release
yum install -y python-pip

# 更改pip镜像源为清华大学的PyPI镜像
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple shadowsocks

# 生成一个随机密码
random_password=$(date +%s | sha256sum | base64 | head -c 12 ; echo)

# 配置 Shadowsocks
cat <<EOF > /etc/shadowsocks.json
{
  "server": "0.0.0.0",
  "port_password": {
    "8388": "$random_password"
  },
  "method": "aes-256-cfb",
  "timeout": 300
}
EOF

# 启动 Shadowsocks 服务
ssserver -c /etc/shadowsocks.json -d start

# 设置开机自启动
cat <<EOF > /etc/systemd/system/shadowsocks.service
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
ExecStart=/usr/bin/ssserver -c /etc/shadowsocks.json
Restart=always
User=nobody

[Install]
WantedBy=multi-user.target
EOF

systemctl enable shadowsocks
systemctl start shadowsocks

echo "Shadowsocks服务器已成功安装和配置！"
echo "服务器地址: $(hostname -I | cut -d ' ' -f 1)"
echo "服务器端口: 8388"
echo "密码: $random_password"
echo "加密方法: aes-256-cfb"
