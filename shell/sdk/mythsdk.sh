#!/bin/dash

# dash 重写mythsdk
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
    
    # nl 然后grep 进行指定的list
    # 目前就是按行号来进行确实配置的, 但是这样就导致了文件过长,拖慢了速度
    i=1
    while [ "$i" -le $lineNum ];do
        # echo "---------------------"$i"----------"
        sdkName=`sed -n $i','$(($i))'p' $configPath`
        sdkInfo=`sed -n $(($i+1))','$(($i+1))'p' $configPath`
        sdkUrl=`sed -n $(($i+2))','$(($i+2))'p' $configPath`
        sdkVersion=`sed -n $(($i+3))','$(($i+3))'p' $configPath`
        printf  "%s\n    %s [%s]\n    %s\n" "$sdkName" "$sdkInfo" "$sdkUrl" "$sdkVersion"
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
        listAllSdk
    ;;
    *)
        a="1 2 3   4"
        for version in $a
        do
            echo 11"$version"
        done
    ;;
esac