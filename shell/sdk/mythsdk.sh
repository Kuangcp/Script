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
    printf "$format" "-up|up|update" "" "更新sdk的配置文件(来源:Gitee)"
    printf "$format" "-l|l|list" "<sdk>" "列出 所有sdk/指定的sdk"
    printf "$format" "-ls|ls|lists " "<sdk>" "列出 所有sdk/指定的sdk 的详细信息"
    printf "$format" "-i|i|install " "sdk <ver>" "下载安装指定sdk的 指定版本/最新版本"
    printf "$format" "-iz|iz " "sdk ver file" "从zip包中安装指定sdk的指定版本 包名:sdk-version.zip  内容:version/bin"
    printf "$format" "-u|u|use " "sdk ver" "使用指定sdk的指定版本"
}

case $1 in 
    -h | h | help)
        help
    ;;
    -up | up | update)
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
    -iz | iz | installZip)
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
    *)
        printf $yellow"请输入参数:\n"
        help
    ;;
esac

# TODO 进入主目录
# TODO 简化 新添加一个sdk的zip时的流程 现在是直接 li, 然后解压正确, 但是要修改配置文件才可以 u  
# 设想是 sed 自动修改配置文件
