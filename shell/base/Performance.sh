#!/bin/bash

# view performance status 

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

help(){
    printf "Run：$red bash Performance.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
    printf "$format" "-s|s" "" "进程状态 按内存降序"
    printf "$format" "-p|p" "" "按名称查看相关进程"
    printf "$format" "-pm|pm" "" "按名称查看相关进程的使用内存统计"
}

showProcessByName(){
    if [ "$1"z = "z" ];then
        echo "please specific process name"
        exit 1
    fi
    ps aux | grep RSS | grep -v "grep" && ps aux | egrep -v "grep" | egrep -v "Performance.sh" | grep -i $1 --color
}

showAllProcess(){
    ps aux | grep -v RSS | awk '{print $6 "\t'$yellow'" $6/1024 "'$end'\t" $2 "\t'$green'" $11 "'$end'"}' | sort --human-numeric-sort -r
}

case $1 in 
    -h|h)
        help ;;
    -s | s)
        showAllProcess | less
    ;;
    -p | p)
        showProcessByName $2 
    ;;
    -pm | pm)
        ps aux | grep RSS | grep -v "grep" && ps aux | egrep -v "grep" | grep -i $2 | awk '{sum+=$6};END {print sum "K " sum/1024"M "}'
    ;;
    -ss|ss)
        while true;do
            showAllProcess | head -n 40
            sleep 3
            clear
        done
    ;;
    *)
        showAllProcess | less
    ;;
esac