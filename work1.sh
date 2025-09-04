#!/bin/bash
#

read -p "请输入操作系统名称：" sys_name

if [ $sys_name = "Linux" -o $sys_name = "linux" ]; then
	echo "红帽"
elif [ $sys_name = "windows" -o $sys_name = "Windows" ]; then
	echo "微软"
elif [ $sys_name = "macos" -o $sys_name = "Macos" ]; then
	echo "苹果"
else 
	echo "其他"
fi
