#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
cyan='\033[0;34m'
pulper='\033[0;35m'
blue='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

userDir=(`cd && pwd`)
# 脚本所在目录
scriptPath=$(cd `dirname $0`; pwd)
currentPath=`pwd`

mainDir=$userDir'/.config/app-conf/RecycleBin'
trashDir=$mainDir'/trash'
infoDir=$mainDir'/info'
logDir=$mainDir'/log'
cnfDir=$mainDir'/conf'

logFile=$logDir'/RecycleBin.log'
configFile=$cnfDir'/main.ini'

# /home/kcp/.local/share/Trash 回收站实际目录

# TODO 文件名最大长度是255, 注意测试边界条件

init(){
    dirs=$trashDir" "$logDir" "$cnfDir" "$infoDir
    for dir in $dirs; do
        if [ ! -d $dir ];then
            mkdir -p $dir
        fi
    done;

    if [ ! -f $logFile ];then
        touch $logFile
    fi
    if [ ! -f $configFile ];then
        echo -e "liveTime=86400\ncheckTime='10m'" > $configFile
    fi

    printf "TrashPath : \033[0;32m"$mainDir"\n\033[0m"
    . $configFile
}

# Delay delete file and shielded signal, Not blocking the current terminal 
delay_delete(){
    result=`ps -ef | grep recycle-bin.sh | grep -v grep | wc -l`
    # Restrict running only one process. But the first run will be 2. 
    # because this function is run by a fork process ?
    if [ "$result" != "2" ];then
        exit
    else
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
        logError "▶ trash is empty    ▌" "script will exit ..."
    fi
}

# move file to trash 
move_file(){
    fileName="$1";
    deleteTime=`date +%s`
    readable=`date +%Y-%m-%d_%H-%M-%S`
    if [ ! -f "$currentPath/$fileName" ] && [ ! -d "$currentPath/$fileName" ] && [ ! -L "$currentPath/$fileName" ];then 
        printf $red"file $fileName not exist \n"
        exit
    fi
    logInfoWithGreen "◆ prepare to delete ▌" "$currentPath/$fileName"
    # 多级目录时, 需要先创建好
    hasDir=`expr match "$fileName" ".*/"`
    if [ ! $hasDir = 0 ]; then 
        #  two way: keep the same dir structure(easy move) or keep deepest dir or file (easy delete)
        # fileDir=${fileName%/*}
        # mkdir -p $trashDir/$fileDir
        simpleFile=${fileName##*/}
        mv "$currentPath/$fileName" "$trashDir/$simpleFile.$readable.$deleteTime"
        return 0
    fi 
    # 全部加上双引号是因为文件名中有可能会有空格
    mv "$currentPath/$fileName" "$trashDir/$fileName.$readable.$deleteTime"
}
move_by_suffix(){
    name=$1
    move_all ".*[^\.][\.]{1}$name\$"
}

# * 通配符删除
move_all(){
    pattern=$1
    if [ "$pattern"1 = "1" ];then
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
        move_file "$file"
    done
}

rollback(){
    if [ "$1"1 = "1" ];then
        printf $red"please select a specific rollback file\n"
        exit 1
    fi
    if [ ! -f $trashDir/$1 ] && [ ! -d $trashDir/$1 ];then
        printf $red"this file not exist \n"
        exit 1
    fi
    file=${1%\.*}
    file=${file%\.*}
    mv $trashDir/$1 $file
    logInfoWithCyan "◀ rollback file     ▌" "$file"
    printf $green"rollback [$file] complete \n"
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
    printf "Run：$red sh recycle-bin.sh$green <verb> $yellow<args>$end\n"
    format="  $green%-5s $yellow%-15s$end%-20s\n"
    printf "$format" "" "file/dir" "move file/dir to trash"
    printf "$format" "-h" "" "show help"
    printf "$format" "-a" "\"pattern\"" "delete file (can't use *, prefer to use +, actually command: ls | egrep \"pattern\")"
    printf "$format" "-as" "suffix" "delete *.suffix"
    printf "$format" "-l" "" "list all file in trash(exclude link file)"
    printf "$format" "-s" "" "search file from trash"
    printf "$format" "-rb" "file" "roll back file from trash"
    printf "$format" "-lo" "file" "show log"
    printf "$format" "-cnf" "" "edit main config file "
    printf "$format" "-b" "" "show background running script"
    printf "$format" "-d" "" "shutdown this script"
    printf "$format" "-upd" "" "upgrade this script when not in git repo"
    printf "$format" "-cl" "" "start check trash dir"
}

show_name_colorful(){
    fileName=$1
    timeStamp=${fileName##*\.}
    fileName=${fileName%\.*}
    time=${fileName##*\.}
    name=${fileName%\.*}
    
    datetime=`echo $time | sed 's/_/ /' | sed 's/-/:/3' | sed 's/-/:/3'`

    # format: datetime filename
    printf "$green $datetime$end $yellow$name$end.$time.$red$timeStamp$end\n"
    # printf " %-30s$green%s$end\n" $name "$time" 
}

# 按删除的日期排序 列出
list_trash_files(){
    # grep r 是为了将一行结果变成多行, 目前不展示link文件
    file_list=`ls --sort=t --time=status -lrAFh $trashDir | egrep -v '^lr' | grep 'r'`
    count=0
    # mode num user group size month day time 
    printf "$blue%-9s %-3s %-5s %-5s %-5s %-19s %-5s$end\n" "   mode  " "num" "user" "group" "size" "      datetime" "        filename "
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

# main entrance: init enviroment for this shell script 
init

assertParamCount(){
    actual=$1
    expect=$2
    if [ ! $1 = $2 ]; then
        printf "$red please input correct param count: $2 $end \n"
        exit 1
    fi
}

# read script params 
case $1 in 
    -h)
        help
    ;;
    -a)
        move_all "$2"
        (delay_delete &)  
    ;;
    -as)
        assertParamCount $# 2
        log_info "\nwill delete: "
        ls | egrep ".*[^\.][\.]{1}$2\$"
        move_by_suffix "$2"
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
        id=`ps -ef | grep "recycle-bin.sh" | grep -v "grep" | grep -v "\-d" | awk '{print $2}'`
        if [ "$id"1 = "1" ];then
            printf $red"not exist background running script\n"$end
        else
            printf $red"pid : $id killed\n"$end
            logWarn "♢ killed script     ▌" "pid: $id"
            kill -9 $id
        fi
    ;;
    -cnf)
        less $configFile
    ;;
    -upd)
        upgrade
    ;;
    -cl)
        (delay_delete &)
    ;;
    *)
        if [ $# = 0 ];then
            printf $red"pelease select specific file\n\n"$end 
            help
            exit
        fi

        for file in "$@" ;do
            printf "=> remove file: [ $file ]\n"
            move_file "$file"
        done
        
        (delay_delete &)
    ;;
esac
