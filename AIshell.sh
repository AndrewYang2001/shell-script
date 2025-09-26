#!/bin/bash
set -euo pipefail

echo "[INFO] 开始部署 AI Shell 环境..."

# 检查是否为 root
if [ "$(id -u)" != "0" ]; then
   echo "错误：请以 root 权限运行此脚本"
   exit 1
fi

# 安装依赖
yum -y groupinstall "Development Tools" || true
yum -y install wget zlib-devel perl-core \
    zlib-devel bzip2-devel openssl-devel ncurses-devel \
    sqlite-devel readline-devel tk-devel gdbm-devel \
    db4-devel libpcap-devel xz-devel || true

# 创建目录
mkdir -p /AI

# 下载安装包
wget -r -nH --cut-dirs=3 -P /AI/ ftp://10.11.0.254/software/AIshell/ || {
    echo "下载失败，请检查 FTP 地址是否可达"
    exit 1
}

# 检查文件是否存在
if [ ! -f "/AI/openssl-1.1.1t.tar.gz" ] || [ ! -f "/AI/Python-3.12.8.tar.xz" ]; then
    echo "错误：缺少必要的安装包"
    ls -l /AI/
    exit 1
fi

# 编译 OpenSSL（不卸载系统版本）
cd /AI/
tar xf openssl-1.1.1t.tar.gz
cd openssl-1.1.1t/
./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl
make && make install

# 设置 OpenSSL 环境
echo 'export PATH=/usr/local/openssl/bin:$PATH' >> /etc/profile
echo '/usr/local/openssl/lib' > /etc/ld.so.conf.d/openssl-1.1.1t.conf
ldconfig
source /etc/profile

ssl_version=$(openssl version | awk '{print $2}')
if [ "$ssl_version" != "1.1.1t" ]; then
    echo "OpenSSL 安装失败，当前版本：$ssl_version"
    exit 1
fi
echo "[OK] OpenSSL 1.1.1t 安装成功"

# 编译 Python
cd /AI/
tar xf Python-3.12.8.tar.xz
cd Python-3.12.8/
./configure --prefix=/usr/local/python3 --with-openssl=/usr/local/openssl
make && make install

# 创建软链接
ln -sf /usr/local/python3/bin/python3 /usr/local/bin/python3
ln -sf /usr/local/python3/bin/pip3 /usr/local/bin/pip3

py_version=$(python3 --version 2>&1 | awk '{print $2}')
if [ "$py_version" != "3.12.8" ]; then
    echo "Python 安装失败，当前版本：$py_version"
    exit 1
fi
echo "[OK] Python 3.12.8 安装成功"

# 安装 shell-gpt
pip3 install --upgrade pip
pip3 install shell-gpt

# 配置 shell-gpt
mkdir -p $HOME/.config/shell_gpt
read -p "请输入 Moonshot API Key: " API_KEY

cat > $HOME/.config/shell_gpt/.sgptrc << EOF
DEFAULT_MODEL=moonshot-v1-8k
OPENAI_API_KEY=${API_KEY}
API_BASE_URL=https://api.moonshot.cn/v1
EOF

echo "[OK] Shell-GPT 配置完成！"
echo "你可以开始使用："
echo "  sgpt '解释这个错误：segmentation fault'"
