#!/bin/bash

# simplify some about file and path action 

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

help(){
    printf "Run：$red bash FileTool.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-16s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
    printf "$format" "" "" "复制当前路径到粘贴板"
    printf "$format" "-f|f" "filename" "当前路径递归搜索文件"
    printf "$format" "-d|d" "dirname" "当前路径递归搜索目录"
    printf "$format" "-p|p" "relative path" "输出相对路径的绝对路径并复制到粘贴板"
    printf "$format" "-cf|cf" "relative path" "复制文件内容到粘贴板"
}

checkParamCount(){
    actual=$1
    expect=$2
    if [ ! $1 = $2 ]; then
        printf "$red please specific fileName $end \n"
        exit 1
    fi
}

case $1 in 
    -h | h)
        help ;;
    -p | p)
        currentPath=`pwd`
        echo $currentPath/$2
        printf $currentPath/$2 | xclip -sel clip
    ;;
	-cf | cf)
		cat $2 | xclip -sel clip
	;;
    -d | d)
        checkParamCount $# 2
        find . -type d -iname "*$2*" 
    ;;
    -f | f)
        checkParamCount $# 2
        find . -type f -iname "*$2*" 
    ;;
    *)
        currentPath=`pwd`
        printf $currentPath/$1 | xclip -sel clip
        # 注意, xclip 会一直存在, 且父进程是 1, 命令执行多次, 也只有一个进程存在, 但是看心情退出????
    ;;
esac

