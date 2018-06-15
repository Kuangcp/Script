#!/bin/sh
# 回收站
userDir=(`cd && pwd`)
currentPath=`pwd`
trashPath=$userDir'/.RecycleBin'
# 日志
logFile=$userDir'/.all.RecycleBin.log'

timeOut=3600 # 存活时间 1小时
checkTime='10m' # 轮询周期 10分钟

# timeOut=5 # 存活时间 5s
# checkTime='1s' # 轮询周期 1s

error='\033[0;31m'
start='\033[0;32m'
end='\033[0m'

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
            log "→ check trash ..."
            ls -A $trashPath | cat | while read line; do
                currentTime=`date +%s`
                removeTime=${line##*\.}
                ((result=$currentTime-$removeTime))
                # echo "$line | $result"
                if [ $result -ge $timeOut ];then
                    log "■ rm -rf $trashPath/$line"
                    rm -rf "$trashPath/$line"
                fi
            done
            fileNum=`ls -A $trashPath | wc -l`
        done
        log "▶ trash is empty. exit..."
    fi
}
moveFile(){
    fileName="$1";
    # echo "input file : $fileName"
    deleteTime=`date +%s`
    log "◆ prepare to delete $currentPath/$fileName"
    if [ ! -f "$currentPath/$fileName" ] && [ ! -d "$currentPath/$fileName" ] && [ ! -L "$currentPath/$fileName" ];then 
        printf $error"file not exist \n"
        exit
    fi
    # 全部加上双引号是因为文件名中有可能会有空格
    mv "$currentPath/$fileName" "$trashPath/$fileName.$deleteTime"
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
        printf $error"no matches found $1 \n"
        exit
    fi
    for file in $list; do
        # echo "$file"
        moveFile "$file"
    done
}
log(){
    content=$1;
    echo `date +%y-%m-%d\ %H:%M:%S`" $content">>$logFile
}
help(){
    printf "Run ./RecycleBin.sh $start <params> $end\n"
    printf "  $start%-16s$end%-20s\n" "-h|help" "show help"
    printf "  $start%-16s$end%-20s\n" "file/dir" "move file/dir to trash dir"
    printf "  $start%-16s$end%-20s\n" "-a \"pattern\"" "all pattern file "
    printf "  $start%-16s$end%-20s\n" "-log" "show log"
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
    *)
        if [ "$1"1 = "1" ];then
            printf $error"pelease select specific file\n" 
            exit
        fi
        moveFile "$1"
        (lazyDelete &)
    ;;
esac
# TODO 从回收站恢复文件