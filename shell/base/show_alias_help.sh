#!/bin/dash

# TODO 重写输出别名文件
path=$(cd `dirname $0`; pwd)
aliasFile=$path/all_alias.conf
start='\033[0;32m'
end='\033[0m'

help(){
    printf "运行：dash show_alias_help.sh $start <params> $end\n"
    printf "  $start%-16s$end%-20s\n" "-h|h|help" "帮助"
    printf "  $start%-16s$end%-20s\n" "1234.." "指定展示文件输出"
    printf "  $start%-16s$end%-20s\n" "-e 1234.." "详细输出"
    printf "  $start%-16s$end%-20s\n" "-l" "输出配置文件"
    printf "  $start%-16s$end%-20s\n" "-e" "编辑配置文件"

}
show(){
    if [ $1"z" = "z" ];then
        help
        exit
    fi
    if [ "$1" -gt 0 ] 2>/dev/null ;then 
        printf ""
    else 
        echo '请输入整数' 
        exit
    fi 
    allLine=`sed -n '$=' $aliasFile`
    if [ $1 -gt $allLine ]; then
        echo "超出范围"
        exit
    fi
    file=`sed -n ${1}p $aliasFile`
    # echo $file
    cat $file | while read line; do
        title=`expr match "$line" "^#\s"`
        if [ $title != 0 ]; then 
            line=${line##*#}
            printf "\n\033[0;35m[ %s ]$end\n" "$line"
        fi
        oneAlias=`expr match "$line" "^alias"`
        if [ $oneAlias != 0 ];then
            # echo $line
            name=${line%=\'*}
            name=${name##*alias}
            command=${line#*=\'}
            command=${command%\'*}
            comment=${line##*\'}
            if [ $2'z' = 'z' ];then 
                printf "$start%-20s$end%-30s\n" "$name" "$comment"
            else
                printf "$start%-20s$end%-30s$start%s$end\n" "$name" "$comment" "$command"
            fi
        fi
    done
}
case $1 in 
    -h | h | help)
        help
    ;;
    -l)
        less $aliasFile
    ;;
    -e)
        vi $aliasFile
    ;;
    -a)
        show $2 1
    ;;
    *)
        show $1
    ;;
esac