#!/bin/bash

#下载相关依赖
set -e
yum -y groupinstall "Development Tools"
yum -y install wget zlib-devel perl-core

#下载martin的ftp里的安装包

mkdir /AI
wget -r -nH --cut-dirs=3 -P /AI/ ftp://10.11.0.254/software/AIshell/

#编译安装python3，openssl1.1.1t

rpm -e --nodeps openssl
cd /AI/
tar xf openssl-1.1.1t.tar.gz
tar xf Python-3.12.8.tar.xz
cd openssl-1.1.1t/
./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl && make && make install

cat << ys >> /etc/profile
export PATH=$PATH:/usr/local/python3/bin:/usr/local/openssl/bin
export LD_LIBRARY_PATH=/usr/local/openssl/lib:$LD_LIBRARY_PATH
ys
source /etc/profile
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
ldconfig
ssl_version=$(openssl version | awk '{print $2}')

if [ $ssl_version != "1.1.1t"  ]; then
    echo "失败，请手动安装openssl"
    break
else
    yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel
    cd /AI/Python-3.12.8/
    ./configure --prefix=/usr/local/python3 --with-openssl=/usr/local/openssl && make && make install
fi
py_version=$(python3 --version | awk '{print $2}')
if [ $py_version != "3.12.8" ]; then
     echo "失败，请手动安装python3"
     break
else
#安装shellgpt

#	read -p "输入AI模型：" MODEL
#	read -p "请输入API地址：" URL
	mkdir .pip
cat << ys > .pip/pip.conf
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/
[install]
trusted-host=mirrors.aliyun.com
ys
pip3 install shell-gpt
mkdir .config/shell_gpt -pv 
cd .config/shell_gpt/
read -p "请输入密钥：" API_KEY
cat << ys > .config/shell_gpt/.sgptrc
DEFAULT_MODEL=moonshot-v1-8k
OPENAI_API_KEY=${API_KEY}
API_BASE_URL=https://api.moonshot.cn/v1
ys
fi
source /etc/profile

