#!/bin/sh
# 回收站
# TODO怎么处理时间的更迭, 单进程已经做到了
userDir=(`cd && pwd`)
currentPath=`pwd`
trashPath=$userDir'/.trash'

init(){
    if [ ! -d $trashPath ];then
        mkdir -p $trashPath
    fi
}
moveFile(){
    printf "Path : \033[0;32m"$trashPath"\n\033[0m"
    fileName="$1";
    if [ ! -f "$trashPath/$fileName" ] && [ ! -d "$trashPath/$fileName" ];then
        # echo "meiyou "$trashPath/$fileName
        mv "$currentPath/$fileName" $trashPath
    else
        for j in $(seq 1 8);do
            if [ ! -f "$trashPath/$fileName.$j" ] && [ ! -d "$trashPath/$fileName.$j" ];then
                mv "$currentPath/$fileName" "$trashPath/$fileName.$j"
                break
            fi
        done
    fi
    lazyDelete
}
help(){
    start='\033[0;32m'
    end='\033[0m'
    printf "Run ./trash.sh $start <params> $end\n"
    printf "  $start%-16s$end%-20s\n" "-h|h|help" "show help"
    printf "  $start%-16s$end%-20s\n" "file/dir" "move file/dir to trash dir"
}
# 延迟删除, 并隐藏屏蔽了信号, 不阻塞当前终端
lazyDelete(){
    result=`ps ux | grep trash.sh | wc -l`
    echo "$result"

    # 为啥是3
    if [ "$result" != "3" ];then
        exit
    else
        (sleep 2h && rm -rf $trashPath/* &)
    fi
    # (sleep 2h && rm -rf $trashPath/* &)
    
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