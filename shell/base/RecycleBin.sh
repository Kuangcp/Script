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
# 日志
logFile=$userDir'/.all.RecycleBin.log'

# liveTime=3600 # 存活时间 1小时
# checkTime='10m' # 轮询周期 10分钟

# DEBUG
liveTime=5 # 存活时间 5s
checkTime='1s' # 轮询周期 1s

init(){
    if [ ! -d $trashPath ];then
        mkdir -p $trashPath
        touch $logFile
    fi
    printf "Path : \033[0;32m"$trashPath"\n\033[0m"
}
# 延迟删除, 并隐藏屏蔽了信号, 不阻塞当前终端
lazyDelete(){
    result=`ps ux | grep RecycleBin.sh | wc -l`
    # echo "$result"
    # 限制只开一个进程, 为啥是3
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
                    log_warn "■ true detetoin     ▌ rm -rf $trashPath/$line"
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
    # echo "input file : $fileName"
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
    if [ "$1"1 = "1" ];then
        printf "delete all file? [y/n] " 
        read answer
        if [ ! "$answer" = "y" ];then
            exit
        fi
    fi
    list=`ls $1`
    num=${#list}
    if [ $num = 0 ];then
        printf $red"no matches found $1 \n"
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
    log_info "◀ rollback file ▌ $file"
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
    printf "Run ./RecycleBin.sh $green <params> $end\n"
    printf "  $green%-16s$end%-20s\n" "-h|help" "show help"
    printf "  $green%-16s$end%-20s\n" "file/dir" "move file/dir to trash dir"
    printf "  $green%-16s$end%-20s\n" "-a \"pattern\"" "all pattern file "
    printf "  $green%-16s$end%-20s\n" "-l " "list file in trash "
    printf "  $green%-16s$end%-20s\n" "-b file" "rollback file from trash "
    printf "  $green%-16s$end%-20s\n" "-log" "show log"
}
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
        ls -lFh $trashPath
    ;;
    -b)
        rollback $2
    ;;
    -down)
        # TODO 杀掉驻留进程
        result=`ps ux | grep Recycle`
        # echo "$result"
        for line in $result; do
            echo $line
        done
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