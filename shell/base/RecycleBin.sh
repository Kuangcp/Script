#!/bin/sh

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
cyan='\033[0;34m'
pulper='\033[0;35m'
blue='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

userDir=(`cd && pwd`)
currentPath=`pwd`
trashPath=$userDir'/.RecycleBin'
logFile=$userDir'/.all.RecycleBin.log'

liveTime=259200 # 存活时间 3天
checkTime='1h' # 轮询周期 1小时 依赖 sleep实现 单位为: d h m s 

# DEBUG
# liveTime=5 # 存活时间 5s
# checkTime='1s' # 轮询周期 1s

# TODO  就差一个记录文件的原始目录的逻辑, 这样就能达到回收站的全部功能了

init(){
    if [ ! -d $trashPath ];then
        mkdir -p $trashPath
        touch $logFile
    fi
    printf "TrashPath : \033[0;32m"$trashPath"\n\033[0m"
}
# 延迟删除, 并隐藏屏蔽了信号, 不阻塞当前终端
lazyDelete(){
    result=`ps -ef | grep RecycleBin.sh | wc -l`
    # echo "$result"
    # 限制只开一个进程, 3 是因为第一次运行才是3
    if [ "$result" != "3" ];then
        exit
    else
        fileNum=`ls -A $trashPath | wc -l`
        while [ ! $fileNum = 0 ]; do
            sleep $checkTime
            log "→ timing detection  ▌ check trash ..."
            ls -A $trashPath | cat | while read line; do
                currentTime=`date +%s`
                removeTime=${line##*\.}
                ((result=$currentTime-$removeTime))
                # echo "$line | $result"
                if [ $result -ge $liveTime ];then
                    log_warn "▶ real delete       ▌ rm -rf $trashPath/$line"
                    rm -rf "$trashPath/$line"
                fi
            done
            fileNum=`ls -A $trashPath | wc -l`
        done
        log_error "▶ trash is empty    ▌ script will exit ..."
    fi
}
moveFile(){
    fileName="$1";
    deleteTime=`date +%s`
    readable=`date +%Y-%m-%d_%H:%M:%S`
    log_info "◆ prepare to delete ▌ $currentPath/$fileName"
    if [ ! -f "$currentPath/$fileName" ] && [ ! -d "$currentPath/$fileName" ] && [ ! -L "$currentPath/$fileName" ];then 
        printf $red"file not exist \n"
        exit
    fi
    # 全部加上双引号是因为文件名中有可能会有空格
    mv "$currentPath/$fileName" "$trashPath/$fileName.$readable.$deleteTime"
}
# * 通配符删除
moveAll(){
    pattern=$1
    if [ "$pattern"1 = "1" ];then
        printf "delete all file? [y/n] " 
        read answer
        if [ ! "$answer" = "y" ];then
            exit
        fi
        pattern="."
    fi
    list=`ls | grep $pattern`
    num=${#list}
    if [ $num = 0 ];then
        printf $red"no matches found $pattern \n"
        exit
    fi
    for file in $list; do
        # echo "$file"
        moveFile "$file"
    done
}
rollback(){
    if [ "$1"1 = "1" ];then
        printf $red"please select a specific rollback file\n"
        exit 1
    fi
    if [ ! -f $trashPath/$1 ] && [ ! -d $trashPath/$1 ];then
        printf $red"this file not exist \n"
        exit 1
    fi
    file=${1%\.*}
    file=${file%\.*}
    mv $trashPath/$1 $file
    log_warn "◀ rollback file     ▌ $file"
    printf $green"rollback [$file] complete \n"
}
log(){
    printf "`date +%y-%m-%d_%H:%M:%S` $1\n" >>$logFile
}
log_error(){
    printf `date +%y-%m-%d_%H:%M:%S`"$red $1\n" >>$logFile
}
log_info(){
    printf `date +%y-%m-%d_%H:%M:%S`"$green $1\n" >>$logFile
}
log_warn(){
    printf `date +%y-%m-%d_%H:%M:%S`"$yellow $1\n" >>$logFile
}
help(){
    printf "Run : ./RecycleBin.sh $green <params> $end\n"
    printf "  $green%-16s$end%-20s\n" "-h|help" "show help"
    printf "  $green%-16s$end%-20s\n" "file/dir" "move file/dir to trash dir"
    printf "  $green%-16s$end%-20s\n" "-a \"pattern\"" "delete file (can't use *, actually command: 'ls | grep \$pattern')"
    printf "  $green%-16s$end%-20s\n" "-l " "list file in trash "
    printf "  $green%-16s$end%-20s\n" "-b file" "rollback file from trash "
    printf "  $green%-16s$end%-20s\n" "-log" "show log"
}
color_name(){
    fileName=$1
    timeStamp=${fileName##*\.}
    fileName=${fileName%\.*}
    time=${fileName##*\.}
    name=${fileName%\.*}
    printf " $green$time$end $name.$time.$red$timeStamp$end\n"
    # printf " %-30s$green%s$end\n" $name "$time" 
}
list_file(){
    file_list=`ls -lFh $trashPath | grep 'r'`
    count=0
    for line in $file_list;do
        count=$(($count + 1))
        if [ $(($count % 9)) = 0 ];then
            color_name $line
        elif [ $(($count % 9)) = 2 ];then
            printf "%s" " $line "
        else
            printf "%-5s" "$line"
        fi
    done
}
# 初始化脚本的环境
init
case $1 in 
    -h | help)
        help
    ;;
    -a)
        moveAll "$2"
        (lazyDelete &)  
    ;;
    -log)
        less $logFile
    ;;
    -l)
        list_file
    ;;
    -b)
        rollback $2
    ;;
    -down)
        id=`ps -ef | grep "RecycleBin.sh" | grep -v "grep" | grep -v "\-down" | awk '{print $2}'`
        if [ $id"1" = "1" ];then
            printf $red"not exist background running script\n"$end
        else
            log_warn "user killed  script ▌ $id"
            kill -9 $id
        fi
    ;;
    *)
        if [ "$1"1 = "1" ];then
            printf $red"pelease select specific file\n"$end 
            help
            exit
        fi
        moveFile "$1"
        (lazyDelete &)
    ;;
esac