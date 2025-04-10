#!/bin/bash

# simplify some about file and path action 
userDir=`cd && pwd`
app_bin="$userDir/Application/bin"

path=$(cd `dirname $0`; pwd)
. $path/base.sh

help(){
    printf "Run：$red bash file-tool.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-8s $yellow%-22s$end%-20s\n"
    
    printf "$format" "-h"     ""                    "Help" 
    printf "$format" ""       ""                    "Copy current path"
    printf "$format" "-f,f"   "filename"            "Search file on current path"
    printf "$format" "-d,d"   "dirname"             "Search dir on current path"

    echo ""
    printf "$format" "-p,p"   "relative_path"       "Copy file path and show it"
    printf "$format" "-cf,cf" "relative_path"       "Copy file content"
    printf "$format" "-cp"    "desktop file"        "Copy file to /usr/share/applications/"

    echo ""
    printf "$format" "-l"     "file dir"            "Link file under dir"
    printf "$format" "-lp"    "file"                "Link file to custom application bin path"
    printf "$format" "-lx"    ""                    "Find broke link file"

    echo ""
    printf "$format" "-b"     "file"                "Rename file to file.bak or reverse it"
    printf "$format" "-t"     "file"                "Rename file.txt to file.20010101.txt"
    printf "$format" "-e"     "file"                "Decompress file"
    printf "$format" "-cs"    "absolute_path count" "Create swap file by absolute path"
    printf "$format" "-ic,ic" "fmt fmt"             "image convert: current dir fmt to target fmt(jpg,png,webp) ag: kf ic png webp"
    
    # printf "\n"
    # printf "$format" "-append" "" "[Python] add current dir to sys.path for python /usr/lib/pythonx.x/site-packages ..."
    # printf "$format" "-dgradle" "" "[Java]   download from https://service.gradle.org/distribution "
    # printf "$format" "-dgo" "" "[Go]     download from https://golang.google.cn/dl/ "
    # printf "$format" "-go" "*.tar.gz" "[Go]     install on /usr/local "
}

assert_param_count(){
    actual=$1
    expect=$2
    if test $1 -lt $2 ; then
        printf "$red please input correct param count: $2 $end \n"
        exit 1
    fi
}

create_swap_file(){
    dir=$1
    count=$2
    if [ -d $dir ] || [ -f $dir ];then 
        printf "$dir already exist!"
        exit 1
    fi

    if [ ! "$count" = "4" ] && [ ! "$count" = "8" ]; then
        printf "only support 4 or 8 Gib\n"
        exit 1
    fi

    count=$(expr $count \* 1024)

    echo "create on " $dir " with size: " $count
    sudo dd if=/dev/zero of=$dir bs=1024k count=$count
    sudo mkswap $dir
    sudo swapon $dir
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

# zsh universalarchive 插件
decompress_file (){
    if [ ! -f $1 ] ; then
        log_error "'$1' is not a valid file"
        exit 1
    fi

    case $1 in
        *.tar)                tar xf $1     ;;
        *.tar.bz2 | *.tbz2)   tar xjf $1    ;;
        *.tar.gz  | *.tgz)    tar xzf $1    ;;
        *.tar.xz  | *.txz)    tar -xJf $1   ;;
        *.tar.Z)              tar -xZf $1   ;;
        *.bz2)                bunzip2 $1    ;;
        *.rar)                unrar x $1    ;;
        *.gz)                 gunzip $1     ;;
        *.rar)                unrar e $1    ;;
        *.zip)                unzip $1      ;;
        *.war | *.jar)        unzip $1      ;;
        *.Z)                  uncompress $1 ;;
        *.xz)                 xz -d $1      ;;
        *.7z)                 7z x $1       ;;
        *.zst)                unzstd $1     ;; # https://github.com/facebook/zstd
        *)           echo "'$1' cannot be extracted" ;;
    esac
}

case $1 in 
    -h | h)
        help ;;
    -l | l)
        assert_param_count $# 3
        ln -s "$(pwd)/$2" "$3/$2"
    ;;
    -lp | lp)
        assert_param_count $# 2
        ln -s "$(pwd)/$2" "$app_bin/$2"
    ;;
    -lx | lx)
        find . -xtype l
    ;;
    -x|x)
        chmod +x $2
    ;;
    -b|b)
        assert_param_count $# 2
        is_match=$(echo $2 | grep -e ".*\.bak$")
        # echo $is_match
        if test -z $is_match; then
            mv "$2" "${2}.bak"
        else 
            origin=${2%.bak*}
            # echo $origin
            mv "$2" "$origin"
        fi
    ;;
    -bt|bt)
        assert_param_count $# 2
        is_match=$(echo $2 | grep -e ".*\.bak\..*$")
        # echo $is_match

        if test -z $is_match; then
            mv "$2" "${2}.bak."$(date +%Y%m%d_%H%M%S)
        else 
            origin=${2%%.bak*}
            # echo $origin
            mv "$2" "$origin"
        fi
    ;;
    -tar|tar)
        file=$2
        if [ ! -f $file ];then 
            log_error "$file is not exist"
            exit 
        fi

        suffix=${file##*\.}
        file_name=${file%\.*}
        mv "$2" "${file_name}.`date "+%Y%m%d-%H:%M:%S"`.$suffix"
    ;;
    -cs)
        create_swap_file $2 $3
    ;;
    -p | p)
        currentPath=`pwd`
        echo $currentPath/$2
        printf $currentPath/$2 | xclip -sel clip
    ;;
    -cp)
        assert_param_count $# 2
        # sudo cp $2 /usr/share/applications/
        cp $2 ~/.local/share/applications
    ;;
	-cf | cf)
		cat $2 | xclip -sel clip
	;;
    # TODO -d -f 都实现多参数, 使其根据两个参数筛选结果
    -d | d)
        pattern=$(get_search_pattern $*)
        find . -type d -iregex $pattern
    ;;
    -e | e)
        assert_param_count $# 2
        shift
        for i in $*; do 
            decompress_file $i
        done 
    ;;
    -t )
        assert_param_count $# 2
        # echo $2
        name=${2%.*}
        suffix=${2##*.}
        # echo $name $suffix
        t=$(date "+%Y%m%d%H%M")
        mv $2 "$name.$t.$suffix"
    ;; 
    -ez | ez)
        assert_param_count $# 2
        # must install unzip-iconv
        unzip -O cp936 $2
    ;;
    -f | f)
        pattern=$(get_search_pattern $*)
        find . -type f -iregex $pattern 
    ;;
    -ic | ic)
        # 将 png/jpg/jpeg 转为目标格式
        if test $# -lt 3; then
            assert_param_count $# 2
            to=$2
            for file in ./*; do
                if test -f "$file" ;  then
                    newFile=$(echo $file | grep -E "\.(png|jpg|jpeg)" | sed "s/\(.*\)\..*/\1.$to/g;")
                    if test -n "$newFile" ; then 
                        if test "$file" = "$newFile" ; then 
                            echo 'same'
                        else
                            echo "convert $file $newFile"
                            echo "rm $file"
                            convert "$file" "$newFile"
                        fi 
                    fi
                fi
            done
            exit
        fi

        # 将 源格式 转为目标格式
        assert_param_count $# 3
        from=$2
        to=$3
        for file in ./*
        do
            if test -f "$file" ;  then
                newFile=$(echo $file | grep "\.$from" | sed "s/\(.*\)\.$from/\1.$to/g;")
                # newFile=$(echo $file | sed "s/\(.*\)\.png/\1.$2/g;s/\(.*\)\.webp/\1.$2/g;s/\(.*\)\.jpg/\1.$2/g")
                # echo "$file" 是文件 $newFile
                if test -n "$newFile" ; then 
                    if test "$file" = "$newFile" ; then 
                        echo 'same'
                    else
                        echo "convert $file $newFile"
                        echo "rm $file"
                        convert "$file" "$newFile"
                    fi 
                fi
            fi
        done
    ;;
    *)
        path=${1#*\./}
        currentPath=`pwd`
        printf $currentPath/$path | xclip -sel clip
        # 注意, xclip 会一直存在, 且父进程是 1, 命令执行多次, 也只有一个进程存在, 但是看心情退出????
    ;;
esac
