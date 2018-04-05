#!/bin/sh
# 回收站
# TODO怎么处理时间的更迭, 单进程已经做到了
userDir=(`cd && pwd`)
currentPath=`pwd`
trashPath=$userDir'/.trash'
# 日志
logFile=$userDir'/.all.trash.log'
# 存活时间
timeOut=10
# 轮询周期
checkTime='5s'
start='\033[0;32m'
end='\033[0m'

init(){
    if [ ! -d $trashPath ];then
        mkdir -phttp://www.cnblogs.com/276815076/archive/2011/10/30/2229286.html $trashPath
        touch $logFile
    fi
}
moveFile(){
    printf "Path : \033[0;32m"$trashPath"\n\033[0m"
    fileName="$1";
    deleteTime=`date +%s`
    mv "$currentPath/$fileName" "$trashPath/$fileName.$deleteTime"
    (lazyDelete &)
}
log(){
    content=$1;
    echo `date +%y-%m-%d\ %H:%M:%S`" $content">>$logFile
}
help(){
    printf "Run ./trash.sh $start <params> $end\n"
    printf "  $start%-16s$end%-20s\n" "-h|h|help" "show help"
    printf "  $start%-16s$end%-20s\n" "file/dir" "move file/dir to trash dir"
}
# 延迟删除, 并隐藏屏蔽了信号, 不阻塞当前终端
lazyDelete(){
    result=`ps ux | grep trash.sh | wc -l`
    # echo "$result"

    # 限制只开一个进程, 为啥是3
    if [ "$result" != "3" ];then
        exit
    else
        fileNum=`ls $trashPath | wc -l`
        while [ ! $fileNum = 0 ]; do
            sleep $checkTime
            log "check trash ..."
            ls $trashPath | cat | while read line; do
                currentTime=`date +%s`
                removeTime=${line##*\.}
                ((result=$currentTime-$removeTime))
                # echo "$line | $result"
                if [ $result -ge $timeOut ];then
                    log "rm -rf $trashPath/$line"
                    rm -rf "$trashPath/$line"
                fi
            done
            fileNum=`ls $trashPath | wc -l`
        done
        log "  trash is empty. exit..."
    fi
}
case $1 in 
    -h | h | help)
        help
    ;;
    *)
        init
        moveFile "$1"
    ;;
esac