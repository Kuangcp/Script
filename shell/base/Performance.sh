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
    printf "$format" "" "[processName][m]" "所有或指定进程状态 按内存降序,m 标记是否统计内存"
    printf "$format" "-p|p" "process interval" "按名称查看相关进程 或者按时间间隔一直查看进程信息"
    printf "$format" "-b" "" "查看该脚本后台进程"
    printf "$format" "-stop" "" "kill 该脚本所有后台进程"
    printf "$format" "-pm|pm" "processName" "按名称查看相关进程的使用内存统计"
    printf "$format" "-ss|ss" "[count]" "查看内存占用最多的几个进程 count默认40个 3s刷新一次"
    printf "$format" "-sum|sum" "[count]" "查看内存占用最多的几个进程 并统计这几个进程内存总占用量"
    printf "$format" "watch" "processName" "10s统计进程总内存 输出到 $logDir/ {processName}.process.log"
}

checkExistProcess(){
    result=$(ps aux | egrep -v "grep" | egrep -v "Performance\.sh.*$1" | grep -i $1 --color)
    if [ ${#result} = 0 ];then
        printf "no process info about $red $1 $end \n"
        exit 0
    fi
}

showProcessByName(){
    if [ $# = 0 ];then
        printf "$red please specific process name $end \n"
        exit 1
    fi
    checkExistProcess $1
    echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
    ps aux | egrep -v "grep" | egrep -v "Performance\.sh.*$1" | grep -i $1 --color
}

showAllProcess(){
    printf "${cyan}KiB\tMiB\tPID\tCommand ${end} \n"
    ps aux | grep -v RSS | awk '{print $6 "\t'$yellow'" $6/1024 "'$end'\t" $2 "\t'$green'" $11 "'$end'"}' | sort --human-numeric-sort -r
    printf "\nmemory sum info\n\n"
    free -h
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

backgroundWatch(){
    checkExistProcess $1
    while true; do
        watchProcess $1 >> $logDir/$1.process.log
    done
}

init 

case $1 in 
    -h|h)
        help ;;
    -p | p)
		if [ "$3"z = "z" ];then
            printf "$red the third param is missing $end \n"
            exit 1
		else
			while true; do
				showProcessByName $2 
				printf "$green...................................................................$end\n"
				sleep $3
			done
		fi
    ;;
    -ss | ss)
        displayCount=40
        if [ ! "$2"z = "z" ];then 
            # validate number
            displayCount=$2
            if [ $2 -lt 10 ];then
                displayCount=$(($2 + 1 ))
                while true; do
                    showAllProcess | head -n $displayCount
                    printf "$green ... $end \n"
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
    -b)
        ps aux | egrep -v "grep" | egrep -v "Performance\.sh -b" | grep -i "Performance.sh" --color
    ;;
    -stop)
        ids=`ps aux | grep "Performance.sh" | egrep -v "grep" | egrep -v "Performance\.sh -d"| awk '{print $2}'`
        if [ "$ids"1 = "1" ];then
            printf $red"not exist background running script $end \n"
        else
            for id in $ids; do
                printf $red"pid : $id killed $end \n"
                kill -9 $id
            done
        fi
    ;;
    -sum|sum)
        displayCount=40
        if [ ! "$2"z = "z" ];then 
            displayCount=$(($2 + 1))
        fi
        result=$(showAllProcess | head -n $displayCount)
        echo "$result"
        printf "\n${green}sum: $end"
        printf "$result" | egrep "^[0-9]" | awk '{sum += $1};END {print sum/1024 " MiB | " sum/1024/1024 " GiB"}'
    ;;
    -watch | watch)
      (backgroundWatch $2 &)  
    ;;
    *)
        if [ $# = 0 ];then
            showAllProcess | less
        elif [ $# = 1 ]; then
            showProcessByName $1 
        elif [ $2 = "m" ];then 
            checkExistProcess $1
            statisticsMemory $1
        elif [ $2 = "s" ];then 
            showProcessByName $1  | less -S 
        fi
    ;;
esac
