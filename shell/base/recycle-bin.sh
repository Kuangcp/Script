#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
cyan='\033[0;34m'
pulper='\033[0;35m'
blue='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

pid=$$

userDir=(`cd && pwd`)
scriptPath=$(cd `dirname $0`; pwd) # 脚本所在目录
currentPath=`pwd`

mainDir=$userDir'/.config/app-conf/RecycleBinDev'
trashDir=$mainDir'/trash'
logDir=$mainDir'/log'
cnfDir=$mainDir'/conf'

logFile=$logDir'/RecycleBin.log'
configFile=$cnfDir'/main.ini'
pidFile=$cnfDir'/pid'

# /home/kcp/.local/share/Trash 回收站实际目录

# TODO 文件名最大长度是255, 注意测试边界条件

init(){
    for dir in $trashDir $logDir $cnfDir; do 
        if [ ! -d $dir ];then
            mkdir -p $dir
        fi
    done

    if [ ! -f $logFile ];then
        touch $logFile
    fi
    if [ ! -f $configFile ];then
        echo -e "liveTime=86400\ncheckTime='10m'" > $configFile
    fi
    
    if test -z $trashDir; then 
        printf $red"config error! trashDir is invalid \n"$end
        exit 1
    fi 

    printf "TrashPath : "$green$mainDir$end"\n"
    . $configFile
}

# Delay delete file and shielded signal, Not blocking the current terminal 
delay_delete(){
    if [ -f $pidFile ]; then 
        exit
    else
        printf $pid > $pidFile
    fi

    fileNum=`ls -A $trashDir | wc -l`
    while [ ! $fileNum = 0 ]; do
        sleep $checkTime
        logInfoWithWhite "→ timing detection  ▌" "check trash ..."
        ls -A $trashDir | cat | while read line; do
            currentTime=`date +%s`
            removeTime=${line##*\.}
            ((result=$currentTime-$removeTime))
            # echo "$line | $result"
            if [ $result -ge $liveTime ];then
                logWarn "▶ real delete       ▌" "rm -rf $trashDir/$line"
                rm -rf "$trashDir/$line"
            fi
        done
        fileNum=`ls -A $trashDir | wc -l`
    done
    logError "▶ trash is empty    ▌" "script will exit. pid: "`cat $pidFile`
    removePid
}

# move file to trash 
lazy_delete_file(){
    fileName="$1";

    if [ ! -f "$currentPath/$fileName" ] && [ ! -d "$currentPath/$fileName" ] && [ ! -L "$currentPath/$fileName" ];then 
        printf $red" $fileName not exist \n"
        exit
    fi
    logInfoWithGreen "◆ prepare to delete ▌" "$currentPath/$fileName"
    hasDir=`expr match "$fileName" ".*/"`
    if [ ! $hasDir = 0 ]; then 
        # file: a/b/c -> c
        simpleFile=${fileName##*/}

        move_file "$fileName" "$simpleFile"
        return 0
    fi
    
    # 全部加上双引号是因为文件名中有可能会有空格
    move_file "$fileName" "$fileName"
}

move_file(){
    origin=$1
    target=$2

    deleteTime=`date +%s`
    readable=`date +%Y-%m-%d_%H-%M-%S`

    mv "$currentPath/$origin" "$trashDir/$target.$deleteTime"
    # echo "$currentPath/$origin" >> "$infoDir/$target.info"
    # echo "$deleteTime" >> "$infoDir/$target.info"
    # echo "$readable" >> "$infoDir/$target.info"
}

lazy_delete_by_suffix(){
    name=$1
    lazy_delete_with_pattern ".*[^\.][\.]{1}$name\$"
}

# * 通配符删除
lazy_delete_with_pattern(){
    pattern=$1
    if test -z "$pattern" ;then
        printf "delete [all]/[exclude hiddened]/[no]?  [a/y/n] : " 
        read answer
        flag=0
        if [ "$answer" = "a" ];then
            list=`ls -A`
            flag=1
        fi
        if [ "$answer" = "y" ];then
            list=`ls -A | grep -v "^\."`
            flag=1
        fi
        if [ $flag = 0 ];then
            exit
        fi
    else
        list=`ls -A | egrep $pattern`
    fi
    # list=`ls -A | grep "$pattern"`
    num=${#list}
    if [ $num = 0 ];then
        printf $red"no matches found $pattern \n"
        exit
    fi
    for file in $list; do
        # echo ">> $file"
        lazy_delete_file "$file"
    done
}

rollback(){
    if test -z $1 ;then
        printf $red"please select a specific rollback file\n"
        exit 1
    fi

    current_file="$1"
    has_str=$(echo $current_file | grep "$trashDir")
    if test -z $has_str; then
        current_file="$trashDir/$1"
    fi
    if [ ! -f $current_file ] && [ ! -d $current_file ] && [ ! -L $current_file ];then
        printf $red" $current_file not exist \n"
        exit 1
    fi
    file=${current_file#*"$trashDir/"}
    file=${file%\.*}
    mv $current_file $file
    logInfoWithCyan "◀ rollback file     ▌" "$file"
    printf $green"Rollback: $cyan$file$end\n"
}

log(){
    printf " $1\n"
}
log_error(){
    printf "$red $1 $end\n" 
}
log_info(){
    printf "$green $1 $end\n" 
}
log_warn(){
    printf "$yellow $1 $end\n" 
}

logInfoWithWhite(){
    printf "`date +%F_%T` $1 $2\n" >>$logFile
}
logInfoWithGreen(){
    printf `date +%F_%T`"$green $1 $2$end\n" >>$logFile
}
logInfoWithCyan(){
    printf `date +%F_%T`"$cyan $1 $2$end\n" >>$logFile
}
logError(){
    printf `date +%F_%T`"$red $1 $2$end\n" >>$logFile
}
logWarn(){
    printf `date +%F_%T`"$yellow $1 $2$end\n" >>$logFile
}

help(){
    printf "Usage：$red bash recycle-bin.sh$green <verb> $yellow<args>$end\n\n"
    printf "    Trash, delete file at delay time that configed \n\n"
    format="  $green%-5s $yellow%-11s $end%-20s\n"

    printf "$format" "-h"     ""             "show help"
    printf "\n"
    printf "$format" ""       "file/dir"     "move file/dir to trash"
    printf "$format" "-a"     "\"pattern\""  "delete file (can't use *, prefer to use +, actually command: ls | egrep \"pattern\")"
    printf "$format" "-as"    "suffix"       "delete *.suffix"
    printf "\n"
    printf "$format" "-l"     ""             "list all file in trash(exclude link file)"
    printf "$format" "-s"     ""             "search file from trash"
    printf "\n"
    printf "$format" "-rb"    "file"         "roll back file from trash"
    printf "\n"
    printf "$format" "-lo"    "file"         "show log"
    printf "$format" "-cnf"   ""             "edit main config file"
    printf "$format" "-cl"    ""             "start check trash that file or dir"
    printf "\n"
    printf "$format" "-b"     ""             "show background running script"
    printf "$format" "-d"     ""             "shutdown this script"
    printf "$format" "-upd"   ""             "upgrade this script when not in git repo"
}

show_name_colorful(){
    fileName=$1

    timeStamp=${fileName##*\.}
    timeStamp=${timeStamp%/*}

    fileName=${fileName%\.*}
    
    time=$(date --date=@$timeStamp "+%Y-%m-%d %H:%M:%S")

    printf "$green $time$end $yellow $fileName$end\n"
    # printf " %-30s$green%s$end\n" $name "$time" 
}

# 按删除的日期排序 列出
list_trash_files(){
    # grep r 是为了将一行结果变成多行, 目前不展示link文件
    fileCounts=$(ls -l $trashDir | wc -l)
    if test $fileCounts -le 1 ; then
        exit
    fi

    file_list=`ls --sort=t --time=status -lrAFh $trashDir | egrep -v '^lr' | grep 'r'`
    count=0
    # mode num user group size month day time 
    printf "$blue%-9s %-3s %-5s %-5s %-5s %-19s %-5s$end\n" "   mode  " "num" "user" "group" "size" " datetime" "  filename "
    printf "${blue}---------------------------------------------------------------------------------------- $end\n"
    for line in $file_list;do
        count=$(($count + 1))
        if [ $(($count % 9)) = 0 ];then
            # actual filename with colorful
            show_name_colorful $line
        elif [ $(($count % 9)) = 2 ];then
            printf "%-4s" " $line"
        elif [ $(($count % 9)) -gt 5 ] && [ $(($count % 9)) -lt 9 ];then
            continue
        else
            printf "%-6s" "$line"
        fi
    done
}

upgrade(){
    curl https://gitee.com/gin9/script/raw/master/shell/base/recycle-bin.sh -o $scriptPath/recycle-bin.sh
    printf $green"upgrade script success\n"$end
}

killScript(){
    scriptPid=$(findProcessPid "recycle-bin.sh")
    # watchPid=$(findProcessPid "$configFile")

    if test -z "$scriptPid"; then
        printf $red"not exist background running script\n"$end
    else
        printf $red"pid : $scriptPid killed\n"$end
        # cat $pidFile
        logWarn "♢ killed script     ▌" "pid: $scriptPid"
        kill $scriptPid
    fi
    # if test -n "$watchPid"; then 
    #     kill $watchPid
    # fi 
}

findProcessPid(){
    id=`ps -ef | grep "$1" | grep -v "grep" | grep -v "\-d" | awk '{print $2}'`
    if test -z $id ; then
        return
    else
        echo $id
    fi
}

watchConfigFile(){
    result=$(ps -ef | grep $configFile | grep -v grep | wc -l)
    if test $result -gt 0; then
        return
    fi

    inotifywait -e modify,delete,create,attrib $configFile
    . $configFile
    logInfoWithGreen "♢ reload config     ▌" "liveTime: $liveTime checkTime: $checkTime "
}

removePid(){
    rm -f $pidFile
}

assertParamCount(){
    actual=$1
    expect=$2
    if [ ! $1 = $2 ]; then
        printf "$red please input correct param count: $2 $end \n"
        exit 1
    fi
}

# main entrance: init enviroment for this shell script 
init

# read script params 
case $1 in 
    -h)
        help
    ;;
    -a)
        lazy_delete_with_pattern "$2"
        (delay_delete &)  
    ;;
    -as)
        assertParamCount $# 2
        log_info "\nwill delete: "
        ls | egrep ".*[^\.][\.]{1}$2\$"
        lazy_delete_by_suffix "$2"
        (delay_delete &)  
    ;;
    -lo)
        less $logFile
    ;;
    -l)
        list_trash_files
    ;;
    -s) 
        assertParamCount $# 2

        list_trash_files | grep "$2"
    ;;
    -rb)
        assertParamCount $# 2
        rollback $2
    ;;
    -b)
        ps aux | grep RSS | grep -v "grep" && ps aux | egrep -v "grep" | grep recycle-bin.sh | grep -v "recycle-bin.sh -b"
    ;;
    -d)
        killScript
        removePid
    ;;
    -cnf)
        less $configFile
    ;;
    -upd)
        upgrade
    ;;
    -cl)
        (delay_delete &)
        # (watchConfigFile &)
    ;;
    *)
        if [ $# = 0 ];then
            printf $red"pelease select specific file\n\n"$end 
            help
            exit
        fi

        for file in "$@" ;do
            printf "=> remove file: [ $file ]\n"
            lazy_delete_file "$file"
        done
        
        (delay_delete &)
        # (watchConfigFile &)
    ;;
esac
