#!/bin/bash

read -p "请输入用户名：" mysql_name
read -p "请输入用户密码：" mysql_passwd

io_stat=$(mysql -u$mysql_name -p$mysql_passwd 2> /dev/null -e "show slave status\G" | sed '1,11d' | head -n 1 | awk -F: '{print $2}')
sql_stat=$(mysql -u$mysql_name -p$mysql_passwd 2> /dev/null -e "show slave status\G" | sed '1,12d' | head -n 1 | awk -F: '{print $2}')

if [ $io_stat == "Yes" ];then 
	echo "1"
else
	echo "0"
fi
if [ $sql_stat == "Yes" ];then
	echo "1"
else
	echo "0"
fi
