#!/bin/dash

# 当前脚本的运行目录
runPath=$(cd `dirname $0`; pwd)
# 拆分文件
. $runPath/config.sh
. $runPath/download.sh

help(){
    format="  $exist%-14s $yellow%-15s$end%-20s\n"
    printf "$format" "-h|h|help" "" "帮助"
    printf "$format" "q" "<domain>" "配置七牛云域名"
    printf "$format" "cnf" "" "进入sdk主目录"
    printf "$format" "export " "" "导出配置文件到当前目录"
    printf "$format" "up|update" "" "更新sdk的配置文件(来源:Gitee)"
    printf "$format" "-l|l|list" "<sdk>" "列出 所有sdk/指定的sdk"
    printf "$format" "-ls|ls|lists " "<sdk>" "列出 所有sdk/指定的sdk 的详细信息"
    printf "$format" "-i|i|install " "sdk <ver>" "下载安装指定sdk的 最新版本/指定版本"
    printf "$format" "-iz|iz " "sdk ver file" "从 zip包 安装指定sdk的指定版本 包名:sdk-version.zip  内容:version/bin"
    printf "$format" "-id|id " "sdk ver dir" "从 目录 安装指定sdk的指定版本 逻辑和上述压缩包一致"
    printf "$format" "-ida|ida " "sdk ver dir" "从 目录 安装指定sdk的指定版本 并加入sdk配置"
    printf "$format" "-a|a " "sdk ver" "添加 sdk version"
    printf "$format" "-u|u|use " "sdk ver" "使用指定sdk的指定版本"
    printf "\n"
    printf "$format" "-append" ""     "[Python] add current dir to sys.path for python /usr/lib/pythonx.x/site-packages ..."
    printf "$format" "-dgradle" ""    "[Java]   download from https://service.gradle.org/distribution "
    printf "$format" "-dgo" ""        "[Go]     download from https://golang.google.cn/dl/ "
    printf "$format" "-go" "*.tar.gz" "[Go]     install on /usr/local "
}

assertParamCount(){
    actual=$1
    expect=$2
    if [ ! $1 = $2 ]; then
        printf "$error please input correct param count: $2 $end \n"
        exit 1
    fi
}

findSDKStartLine(){
    sdk=$1
    count=0
    cat $configPath | while read line; do
        count=$(($count+1))

        # echo "$count $line"
        has_str=$(echo "$line" | grep $sdk)

        # echo "$count $line $has_str"
        if test -z "$has_str";then
            continue
        else
            return $count
        fi
    done
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

case $1 in 
    -h | h | help)
        help
    ;;
    up | update)
        updateConfig
    ;;
    -l | l | list)
        loadConfig
        listAllSdk 1 $2 | less
    ;;
    -ls | ls | lists)
        loadConfig
        listAllSdk 0 $2 | less
    ;;
    -i | i | install)
        downByQiNiu $2 $3
    ;;
    -id | id | installDir)
        assertParamCount $# 4
        mv $4 $3
        file=$2-$3.zip
        zip -r $file $3
        handleLocalZip $2 $3 $file
    ;;
    -ida | ida)
        assertParamCount $# 4
        sdk=$2
        ver=$3
        dir=$4

        mv $dir $ver
        file=$sdk-$ver.zip
        zip -r $file $ver
        
        addSdkVersion $sdk $ver

        handleLocalZip $sdk $ver $file
    ;;
    export)
        printf "export current from %s \n"  $configPath
        cp $configPath .
    ;;
    -a | a)
        assertParamCount $# 3
        addSdkVersion $2 $3
    ;;
    -iz | iz | installZip)
        assertParamCount $# 4
        handleLocalZip $2 $3 $4
    ;;
    -q | q | qiNiu)
        echo "domain="$2"/">$secretPath
    ;;
    -u | u | use)
        changeVersion $2 $3 
    ;;
    cnf)
        echo $basePath
    ;;
        -append)
        add_python_sys_path
    ;;
    -go)
        if [ -f $2 ]; then
            sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $2 
        fi
    ;;
    -dgo)
        tmp_file="/tmp/down-go"
        rootURL='https://golang.google.cn'
        curl -s https://golang.google.cn/dl/ > $tmp_file
        cat $tmp_file | grep -e ".*linux-amd.*td" | head -n 20 | cut -d '"' -f 6 | awk '{printf("%2d %s\n", NR, $0);}'
        printf "select which download (1-20):"
        read no
        url=$(grep -e ".*linux-amd.*td" $tmp_file | sed -n ${no}p | cut -d '"' -f 6)
        
        url=$rootURL$url
        echo $url
        wget $url
    ;;
    -dgradle)
        tmp_file="/tmp/down-gradle"
        rootURL='https://services.gradle.org'
        curl -s $rootURL/distributions/ > $tmp_file
        cat $tmp_file | grep "bin\.zip\"" | head -n 20 | cut -d '"' -f 2 | awk '{printf("%2d %s\n", NR, $0);}'
        printf "select which download (1-20):"
        read no
        line=$(grep "bin\.zip\"" $tmp_file | sed -n ${no}p | cut -d '"' -f 2)
        
        url="$rootURL$line"
        echo $url
        wget $url
    ;;
    *)
        printf $yellow"请输入参数:\n"
        help
    ;;
esac

# TODO 进入主目录
# TODO 简化 新添加一个sdk的zip时的流程 现在是直接 li, 然后解压正确, 但是要修改配置文件才可以 u  
# 设想是 sed 自动修改配置文件
