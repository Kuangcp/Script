#!/bin/dash

# 配置文件严格格式, 四行配置 空行分隔

jsonUrl='https://gitee.com/kcp1104/script/raw/master/python/mythsdk/config.json'
qiNiu=''
# githubUrl='https://raw.githubusercontent.com/kuangcp/Apps/master/zip/'
# bashPath='~/.mythsdk/'
userDir=`cd && pwd`
basePath=$userDir'/test/sdk/'
# configPath=$basePath'config.json'
configPath='config.md'

# 初始化目录结构
initDir(){
    echo $basePath
    if [ ! -d $basePath ];then 
        echo "不存在目录"$basePath
        mkdir -p $basePath"zip" && mkdir -p $basePath"sdk"
    fi
}
# 加载配置文件,如果本地没有就去默认URL下载
loadConfig(){
    initDir
    if [ ! -f $configPath ];then
        curl -o $configPath $jsonUrl
    fi
}

listAllSdk(){
    lineNum=`cat $configPath | wc -l ` # 比真实行数少一行
    start='\033[0;32m'
    end='\033[0m'
    # nl 然后grep 进行指定的list
    # 目前就是按行号来进行确实配置的, 但是这样就导致了文件过长,拖慢了速度
    i=1
    while [ "$i" -le $lineNum ];do
        sdkName=`sed -n $i','$(($i))'p' $configPath`
        sdkInfo=`sed -n $(($i+1))','$(($i+1))'p' $configPath`
        sdkUrl=`sed -n $(($i+2))','$(($i+2))'p' $configPath`
        sdkVersion=`sed -n $(($i+3))','$(($i+3))'p' $configPath`
        
        if [ "# "$2 = "# " ];then
            printf "\033[1;34m%s$end " "$sdkName"
            if [ $1"z" = "0z" ];then
                printf "\033[0;35m %s$end  \033[1;31m%s\n    " "$sdkInfo" "$sdkUrl" 
            fi
            printf "\n    $start"
            for version in $sdkVersion
            do
                printf $version"  "
            done
            printf $end"\n"
        elif [ "# "$2 = "$sdkName" ];then
            printf "\033[1;34m%s$end " "$sdkName"
            if [ $1"z" = "0z" ];then
                printf "\033[0;35m %s$end  \033[1;31m%s\n    " "$sdkInfo" "$sdkUrl" 
            fi
            printf "\n    $start"
            for version in $sdkVersion
            do
                printf $version"  "
            done
            printf $end"\n"
        fi
        i=$(($i+5))
    done
}

case $1 in 
    -h | h | help)
        format="  %-18s%s\n"
        printf "$format" "-h|h|help" "帮助"
        printf "$format" "-l|l|list" "列出所有sdk"
    ;;
    -l | l | list)
        listAllSdk 1 $2
    ;;
    -ls | ls | lists)
        listAllSdk 0 $2
    ;;
    *)
        a="1 2 3   4"
        for version in $a
        do
            echo 11"$version"
        done
    ;;
esac


# python  myth.py <params> ：
#      l|list <sdk>： 
#         输出所有可安装的sdk,指定则输出指定sdk信息
#      h|help :
#         帮助信息
#      q domain :
#         配置存放了sdk的七牛云地址 http://xxx/
#      up|update :
#         更新配置文件，即sdk库
#      u|use sdk version :
#         使用已安装的指定sdk的版本
#      i|install sdk <version> : 
#         安装指定版本，不指定则安装最新版
