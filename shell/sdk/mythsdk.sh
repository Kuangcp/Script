#!/bin/dash

# 当前脚本的运行目录
runPath=$(cd `dirname $0`; pwd)
# 拆分文件
. $runPath/config.sh
. $runPath/download.sh

help(){
    format="  %-18s%s\n"
    printf "$format" "-h|h|help" "帮助"
    printf "$format" "-up|up|update" "更新sdk的配置文件"
    printf "$format" "-l|l|list <sdk>" "列出所有sdk或者指定的sdk"
    printf "$format" "-ls|ls|lists <sdk>" "列出所有sdk或者指定的sdk的详细信息"
    printf "$format" "-i|i|install <sdk> <version>" "下载安装某sdk的某版本"
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
        listAllSdk 1 $2
    ;;
    -ls | ls | lists)
        loadConfig
        listAllSdk 0 $2
    ;;
    -i | i | install)
        downByQiNiu $2 $3
    ;;
    -q | q | qiNiu)
        echo "domain="$2>$secretPath
    ;;
    *)
    ;;
esac


# python  myth.py <params> ：
#      u|use sdk version :
#         使用已安装的指定sdk的版本
#      i|install sdk <version> : 
#         安装指定版本，不指定则安装最新版

# 下载文件, 然后解压, 添加软连接以及current文件, 增加删除操作