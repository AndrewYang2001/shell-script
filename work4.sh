#!/bin/bash

read -p "请输入服务名称：" service_name

service_stat=$(systemctl status $service_name | grep "Active" | awk '{print $2}')
service_time=$(systemctl status $service_name | grep "Active" | awk '{print $5,$6,$7,$8}')
service_PID=$(systemctl status $service_name | grep "Main PID" | awk '{print $3}')
service_port=$(netstat -tunlp | grep $service_name | head -n 1 | awk '{print $4}' | awk -F: '{print $2}')
if [ $service_stat == "active" ]; then
	echo "已启动，服务名：${service_name}，PID=${service_PID}，端口号：${service_PID}，启动时间：${service_time}"
else
	echo "服务已经启动"
fi


