#!/bin/bash

# simplify some about file and path action 

path=$(cd `dirname $0`; pwd)
. $path/base.sh

help(){
    printf "Run：$red bash FileTool.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-16s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
    printf "$format" "" "" "复制当前路径到粘贴板"
    printf "$format" "-f|f" "filename" "当前路径递归搜索文件"
    printf "$format" "-d|d" "dirname" "当前路径递归搜索目录"
    printf "$format" "-p|p" "relative path" "输出相对路径的绝对路径并复制到粘贴板"
    printf "$format" "-cf|cf" "relative path" "复制文件内容到粘贴板"
    printf "$format" "-l" "file targetDIr" "链接文件到指定目录"
    printf "$format" "-b" "file" "文件或目录加 .bak"
    printf "$format" "-ub" "file" "文件或目录删除 .bak"
}

assertParamCount(){
    actual=$1
    expect=$2
    if [ ! $1 = $2 ]; then
        printf "$red please input correct param count: $2 $end \n"
        exit 1
    fi
}

get_search_pattern(){
    pattern=""
    verb=$1

    for temp in $*; do
        pattern=$pattern".*"$temp
    done
    pattern=$pattern".*"
    pattern=${pattern#*$verb}
    echo $pattern
}

case $1 in 
    -h | h)
        help ;;
    -l)
        assertParamCount $# 3
        ln -s $(pwd)/$2 $3/$2
    ;;
    -b)
        assertParamCount $# 2
        mv $2 ${2}.bak
    ;;
    -ub)
        assertParamCount $# 2
        origin=${2%.bak*}
        mv $2 $origin
    ;;
    -p | p)
        currentPath=`pwd`
        echo $currentPath/$2
        printf $currentPath/$2 | xclip -sel clip
    ;;
	-cf | cf)
		cat $2 | xclip -sel clip
	;;
    # TODO -d -f 都实现多参数, 使其根据两个参数筛选结果
    -d | d)
        pattern=$(get_search_pattern $*)
        find . -type d -iregex $pattern
    ;;
    -f | f)
        pattern=$(get_search_pattern $*)
        find . -type f -iregex $pattern 
    ;;
    -me)
        assertParamCount $# 2
        file=$2
        
        for i in $(ls); do cat $i >> $file; done
    ;;
    *)
        path=${1#*\./}
        currentPath=`pwd`
        printf $currentPath/$path | xclip -sel clip
        # 注意, xclip 会一直存在, 且父进程是 1, 命令执行多次, 也只有一个进程存在, 但是看心情退出????
    ;;
esac

