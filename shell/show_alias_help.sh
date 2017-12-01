#!bin/sh

# TODO 重写输出别名文件

aliasFile="/home/kcp/.bash_aliases"
# aliases=`cat ~/.bash_aliases`
# echo $aliases
cat $aliasFile | while read line
do
    echo $line
done
