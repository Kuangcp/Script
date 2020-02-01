#!/bin/bash

# simplify some about file and path action 
userDir=`cd && pwd`
app_bin="$userDir/Application/bin"

path=$(cd `dirname $0`; pwd)
. $path/base.sh

help(){
    printf "Run：$red bash file-tool.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-8s $yellow%-22s$end%-20s\n"
    printf "$format" "-h" "" "help"
    printf "$format" "" "" "copy current path"
    printf "$format" "-f|f" "filename" "search file on current path"
    printf "$format" "-d|d" "dirname" "search dir on current path"
    printf "$format" "-p|p" "relative path" "copy file path and show it"
    printf "$format" "-cf|cf" "relative path" "copy file content"
    printf "$format" "-cs" "absolute_path count" "create swap file by absolute path"
    printf "$format" "-l" "file dir" "link file under dir"
    printf "$format" "-lp" "file" "link file to customer bin"
    printf "$format" "-b" "file" "change file between file.bak with file"
    printf "$format" "-e" "file" "decompress file"
    printf "\n"
    printf "$format" "-append" "" "[python] add current dir to sys.path for python /usr/lib/pythonx.x/site-packages ..."
    printf "$format" "-dg" "" "[go] download latest go from https://golang.google.cn/dl/ "
    printf "$format" "-go" "*.tar.gz" "[go] install go on /usr/local "
}

assert_param_count(){
    actual=$1
    expect=$2
    if [ ! $1 = $2 ]; then
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

add_python_sys_path(){
    lib_path='/usr/local/lib'
    project=$(pwd)
    
    log_info "Please select a python version"
    versions=$(ls $lib_path | grep "python")
    for version in $versions; do
        echo "  " $version 
    done
    read version
    if [ ! -d $lib_path/$version ];then 
        log_error "target dir not exist: $lib_path/$version"
    fi
    
    log_info "Please input filename, result: $lib_path/$version/dist-packages/filename.pth"
    while true; do
        read filename
        if [ -f "$lib_path/$version/dist-packages/$filename.pth" ];then
            log_warn "$filename already exist"
        else 
            break
        fi
    done
    sudo sh -c "echo $project"/" >> $lib_path/$version/dist-packages/$filename.pth"
    log_info "add success: $lib_path/$version/dist-packages/$filename.pth"
}

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
        *.Z)                  uncompress $1 ;;
        *.xz)                 xz -d $1      ;;
        *.7z)                 7z x $1       ;;
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
        decompress_file $2
    ;;
    -f | f)
        pattern=$(get_search_pattern $*)
        find . -type f -iregex $pattern 
    ;;
    -append)
        add_python_sys_path
    ;;
    -go)
        if [ -f $2 ]; then
            sudo tar -C /usr/local -xzf $2 
        fi
    ;;
    -dgo)
        tmp_file="/tmp/down-go"
        curl -s https://golang.google.cn/dl/ > $tmp_file
        cat $tmp_file | grep -e "https.*linux-amd" | head -n 20 | awk '{print $4}' | cut -d '"' -f 2 | awk '{printf("%2d %s\n", NR, $0);}'
        printf "select which download (1-20):"
        read no
        url=$(cat $tmp_file | grep -e "https.*linux-amd" | head -n 20 | sed -n ${no}p | awk '{print $4}' | cut -d '"' -f 2)
        echo $url
        wget $url
    ;;
    -dgradle)
        tmp_file="/tmp/down-gradle"
        curl -s https://services.gradle.org/distributions/ > $tmp_file
        cat $tmp_file | grep "bin\.zip\"" | head -n 20 | awk '{printf("%2d %s\n", NR, $0);}'
        printf "select which download (1-20):"
        read no
        line=$(cat $tmp_file | grep "bin\.zip\"" | head -n 20 | sed -n ${no}p | cut -d '"' -f 2)
        url="https://services.gradle.org$line"
        echo $url
        wget $url
    ;;
    *)
        path=${1#*\./}
        currentPath=`pwd`
        printf $currentPath/$path | xclip -sel clip
        # 注意, xclip 会一直存在, 且父进程是 1, 命令执行多次, 也只有一个进程存在, 但是看心情退出????
    ;;
esac
