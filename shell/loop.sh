#!/bin/bash
# 一定要使用bash运行
for i in {0..1000..1}
  do
	sleep 1
	curl -s -o /dev/null http://210.35.16.80/
# 循环访问网页
