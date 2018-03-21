#!/bin/dash

# TODO 重写输出别名文件

aliasFile="/home/kcp/.kcp_aliases"

cat $aliasFile  | while read line
do
    printf "$line\n"    
done
