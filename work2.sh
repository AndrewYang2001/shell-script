#!/bin/bash
#

read -p "请输入磁盘名称：" dev_name

use=$(df -Th $dev_name | sed '1d' | awk '{print $6}' | sed 's/%//')
if [ "$use" -ge 10 ];then
	echo "警告"
else
	echo "正常"
fi

