#!/bin/bash
pid=$$
# view performance status 
path=$(cd `dirname $0`; pwd)
. $path/base.sh

userDir=(`cd && pwd`)
logDir=$userDir'/.config/app-conf/log'

init(){
    if [ ! -d $logDir ];then
        mkdir -p $logDir
    fi
}

check_exist_process(){
    result=$(ps aux | egrep -v "grep" | egrep -v "process-tool\.sh.*$1" | grep -i $1 --color)
    if [ ${#result} = 0 ];then
        printf "no process info about $red $1 $end \n"
        exit 0
    fi
}

show_process_by_name(){
    if [ $# = 0 ];then
        printf "$red please specific process name $end \n"
        exit 1
    fi
    check_exist_process $1
    echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
    ps aux | egrep -v "grep" | egrep -v "process-tool\.sh.*$1" | grep -i $1 --color
}

show_all_processes(){
    printf "${cyan}KiB\tMiB\tPID\tCPU\tCommand ${end} \n"
    ps aux | grep -v RSS | awk '{print $6 "\t'$yellow'" $6/1024 "'$end'\t" $2 "\t"$3 "\t'$green'" $11 "'$end'"}' | sort --human-numeric-sort -r
    # printf "\nmemory sum info\n\n"
    free -h
}

# TODO remove last process, self ? 
show_all_processes_sort_cpu(){
    process=$1
    if test -z $process; then
        process="*"
    fi
    printf "${cyan}CPU\tMiB\tPID\tCommand ${end} \n"
    ps aux | grep "$process" | grep -v "$pid" | grep -v "grep" | grep -v RSS | awk '{print $3 "\t'$yellow'" $6/1024 "'$end'\t" $2 "\t'$green'" $11 "'$end'"}' | sort -hr
}

statistic_memory(){
    ps aux | egrep -v "grep" | grep -i $1 | awk '{sum+=$6};END {sum-=2800;print sum "K " sum/1024"M "}'
}

watch_process(){
    date +%s | xargs printf
    printf "$green `date "+%Y-%m-%d %H:%M:%S"` $end"
    statistic_memory $1 
    sleep 10
}

sum_proces(){
    displayCount=40
    if [ ! "$1"z = "z" ];then 
        displayCount=$(($1 + 1))
    fi
    
    result=$(show_all_processes | head -n $displayCount)
    echo "$result"

    printf "\n${green}sum: $end"
    printf "$result" | egrep "^[0-9]" | awk '{sum += $1};END {print sum/1024 " MiB | " sum/1024/1024 " GiB"}'
}

sort_process(){
    displayCount=40
    if [ ! "$1"z = "z" ];then 
        # validate number
        displayCount=$1
        if [ $1 -lt 10 ];then
            displayCount=$(($1 + 1 ))
            while true; do
                show_all_processes | head -n $displayCount
                printf "$green...................... $end \n"
                sleep 3
            done
        fi
    fi
    while true; do
        show_all_processes | head -n $displayCount
        sleep 3
        clear
    done
}

# kill self process
kill_self(){
    ids=`ps aux | grep "process-tool.sh" | egrep -v "grep" | egrep -v "process-tool\.sh -d"| awk '{print $2}'`
    if [ "$ids"1 = "1" ];then
        printf $red"not exist background running script $end \n"
    else
        for id in $ids; do
            printf $red"pid : $id killed $end \n"
            kill -9 $id
        done
    fi
}

list_process_by_name(){
    if [ $# != 3 ];then
        printf "$red the third param is missing $end \n"
        exit 1
    else
        while true; do
            show_process_by_name $2
            printf "$green...................................................................$end\n"
            sleep $3
        done
    fi
}

background_watch(){
    check_exist_process $1
    while true; do
        watch_process $1 >> $logDir/$1.process.log
    done
}

help(){
    printf "Run：$red bash process-tool.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-10s $yellow%-22s$end%-20s\n"
    printf "$format" "-h" "" "help"
    printf "$format" "" "[process][m|s]" "status of process sort by memory. m flag count memory; s flag show line with no wrap;"
    printf "$format" "-cpu|cpu" "" "sort by cpu desc"
    printf "$format" "-p|p" "process interval" "按名称查看相关进程 并按时间间隔一直查看进程信息"
    printf "$format" "-b" "" "查看该脚本后台进程"
    printf "$format" "-stop" "" "kill 该脚本所有后台进程"
    printf "$format" "-ss|ss" "[count]" "查看内存占用最多的几个进程 count默认40个 3s刷新一次"
    printf "$format" "-sum|sum" "[count]" "查看内存占用最多的几个进程 并统计这几个进程内存总占用量"
    printf "$format" "watch" "process" "10s统计进程总内存 输出到 $logDir/ {process}.process.log"
}

init 
case $1 in 
    -h | h)
        help 
    ;;
    -p | p)
        list_process_by_name $@
    ;;
    -cpu | cpu)
        show_all_processes_sort_cpu $2 | less
    ;;
    -ss | ss)
        sort_process $2
    ;;
    -b)
        ps aux | egrep -v "grep" | egrep -v "process-tool.sh -b" | grep -i "process-tool.sh" --color
    ;;
    -stop)
        kill_self
    ;;
    -sum|sum)
        sum_proces $2 
    ;;
    -watch | watch)
      (background_watch $2 &)  
    ;;
    *)
        if [ $# = 0 ];then
            show_all_processes | less
        elif [ $# = 1 ]; then
            show_process_by_name $1 
        elif [ $2 = "m" ];then 
            check_exist_process $1
            statistic_memory $1
        elif [ $2 = "s" ];then 
            show_process_by_name $1  | less -S 
        fi
    ;;
esac
