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
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
    printf "$format" "" "" "复制当前路径到粘贴板"
    printf "$format" "-p|p" "relative path" "输出相对路径的绝对路径并复制到粘贴板"
    printf "$format" "-cf|cf" "relative path" "复制文件内容到粘贴板"
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
    -f | f)
        if [ "$2"z = "z" ];then
            echo "please specific fileName"
            exit 1
        fi
        find . -iname "*$2*" 
    ;;
    *)
        currentPath=`pwd`
        printf $currentPath/$1 | xclip -sel clip
    ;;
esac