#!/bin/dash

# TODO 重写输出别名文件

aliasFile="all_alias.conf"


help(){
    start='\033[0;32m'
    end='\033[0m'
    printf "运行：dash check_desktop.sh $start <params> $end\n"
    printf "  $start%-16s$end%-20s\n" "-h|h|help" "帮助"
}

case $1 in 
    -h | h | help)
        help
    ;;
    -a)
        cat $aliasFile
    ;;
    *)
        if [ $1"z" = "z" ];then
            echo "请指定别名文件"
            exit
        fi
        allLine=`sed -n '$=' $aliasFile`
        if [ $1 -gt $allLine ]; then
            echo "超出范围"
            exit
        fi
        file=`sed -n ${1}p $aliasFile`
        echo $file
        cat $file | while read line; do
            # echo $line
            clean=`expr match "$line" "^alias"`
            if [ $clean != 0 ];then
                echo $line
                name=${line%=*}
                name=${name##*alias}
                echo $name
            fi
        done  
    ;;
esac