#!/bin/bash
#系统docker环境部署
#导入 Docker APT 存储库 GPG 密钥
apt install gpg -y

curl  -fsSL  https://download.docker.com/linux/ubuntu/gpg| sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg

#将存储库添加到 Apt 源：
echo "deb https://download.docker.com/linux/ubuntu  noble stable" | sudo tee /etc/apt/sources.list.d/docker.list

#更新系统中的存储库列表以确认其正常工作
# 软件库升级
apt update
echo "软件库升级完成"

# 安装所需软件
apt install unzip wget curl redis-server vim docker.io -y

# 安装docker-compose 最新版本

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
echo "软件安装完成"

# 下载 mosdns
wget https://github.com/IrineSistiana/mosdns/releases/download/v4.5.3/mosdns-linux-amd64.zip
echo "下载 mosdns 完成"
wget https://github.com/haotianlPM/easymosdns-k/releases/download/v1.0.0/easymosdns-k.zip
echo "下载 easymosdns 完成"

# 解压 mosdns
sudo unzip mosdns-linux-amd64.zip "mosdns" -d /usr/local/bin
sudo chmod +x /usr/local/bin/mosdns
echo "解压并设置 mosdns 完成"

# 解压 easymosdns
unzip easymosdns-k.zip
sudo mv easymosdns-k-main /etc/mosdns
echo "解压并设置 easymosdns 完成"

# 创建 /etc/systemd/resolved.conf.d 目录
sudo mkdir -p /etc/systemd/resolved.conf.d
echo "创建 /etc/systemd/resolved.conf.d 目录完成"

# 创建 /etc/systemd/resolved.conf.d/dns.conf 文件
sudo tee /etc/systemd/resolved.conf.d/dns.conf <<EOF
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
EOF
echo "创建 /etc/systemd/resolved.conf.d/dns.conf 文件完成"

# 备份并创建符号链接 /etc/resolv.conf
sudo mv /etc/resolv.conf /etc/resolv.conf.backup
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
echo "备份并创建符号链接 /etc/resolv.conf 完成"

# 重新加载或重启 systemd-resolved
sudo systemctl reload-or-restart systemd-resolved
echo "重新加载或重启 systemd-resolved 完成"

# 安装并启动 mosdns 服务
sudo mosdns service install -d /etc/mosdns -c config.yaml
sudo mosdns service start
echo "安装并启动 mosdns 服务完成"
