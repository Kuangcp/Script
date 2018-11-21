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

userDir=(`cd && pwd`)
logDir=$userDir'/.config/app-conf/log'

init(){
    if [ ! -d $logDir ];then
        mkdir -p $logDir
    fi
}

help(){
    printf "Run：$red bash Performance.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-8s $yellow%-20s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
    printf "$format" "" "[processName]" "所有或指定进程状态 按内存降序"
    printf "$format" "-p|p" "process interval" "按名称查看相关进程 或者按时间间隔一直查看进程信息"
    printf "$format" "-pm|pm" "processName" "按名称查看相关进程的使用内存统计"
    printf "$format" "-ss|ss" "[count]" "查看内存占用最多的几个进程 count默认40"
    printf "$format" "watch" "processName" "10s统计进程总内存 输出到 $logDir"
}

showProcessByName(){
    if [ "$1"z = "z" ];then
        echo "please specific process name"
        exit 1
    fi
    echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"  && ps aux | egrep -v "grep" | egrep -v "Performance.sh" | grep -i $1 --color
}

showAllProcess(){
    printf "${cyan}K\tM\tPID\tCommand\n${end}"
    ps aux | grep -v RSS | awk '{print $6 "\t'$yellow'" $6/1024 "'$end'\t" $2 "\t'$green'" $11 "'$end'"}' | sort --human-numeric-sort -r
}

statisticsMemory(){
    ps aux | egrep -v "grep" | grep -i $1 | awk '{sum+=$6};END {sum-=2800;print sum "K " sum/1024"M "}'
}

watchProcess(){
    date +%s | xargs printf
    printf "$green `date "+%Y-%m-%d %H:%M:%S"` $end"
    statisticsMemory $1 
    sleep 10
}

init 

case $1 in 
    -h|h)
        help ;;
    -p | p)
		if [ "$3"z = "z" ];then
            echo 'the second param invalid'
            exit 1
		else
			while true; do
				showProcessByName $2 
				echo ...................................................................
				sleep $3
			done
		fi
    ;;
    -pm | pm)
        statisticsMemory $2
    ;;
    -ss | ss)
        displayCount=40
        echo "pid  |  memory(M)  |  memory(K)  |  Command"
        if [ ! "$2"z = "z" ];then 
            # validate number
            displayCount=$2
            if [ $2 -lt 10 ];then
                while true; do
                    showAllProcess | head -n $2
                    echo "..."
                    sleep 3
                done
            fi
        fi
        while true; do
            showAllProcess | head -n $displayCount
            sleep 3
            clear
        done
    ;;
    -watch | watch)
        while true; do
            watchProcess $2 >> $logDir/$2.process.log
        done
    ;;
    *)
        if [ "$1"z = "z" ];then
            showAllProcess | less
        else
            showProcessByName $1 
        fi
    ;;
esac
