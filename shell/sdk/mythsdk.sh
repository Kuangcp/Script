#!/bin/dash

# 配置文件严格格式, 一个sdk四行配置(每一行行首都不能有空格)
# SDK之间只有一行空行分隔, sdk名字后不能有空格 sdk版本之间用空格分隔

jsonUrl='https://raw.githubusercontent.com/Kuangcp/Script/master/shell/sdk/config.md'
qiNiu=''
# githubUrl='https://raw.githubusercontent.com/kuangcp/Apps/master/zip/'
# bashPath='~/.mythsdk/'
userDir=`cd && pwd`
basePath=$userDir'/test/mythsdk/'
configPath=$basePath'config.md'
secretPath=$basePath'secret.conf'

error='\033[1;31m'
current='\033[0;31m'
exist='\033[0;32m'
end='\033[0m'

createDir(){
    if [ ! -d $1 ];then 
        mkdir -p $1
    fi
}
updateConfig(){
    curl -o $configPath $jsonUrl
}
# 初始化目录结构, 加载配置文件, 如果本地没有就去默认URL下载
loadConfig(){
    createDir $basePath"zip"
    createDir $basePath"sdk"
    if [ ! -f $configPath ];then
        updateConfig
    fi
}
# 因为sdk 是#后有空格, 所以导致了三个参数进来, 恰巧这个空格省去了我切分出sdk的名字
# 查询sdk是否有对应版本的目录, 有就说明下载了, 如果bin目录下有current文件,说明正在使用
querySDKExist(){
    if [ -f $basePath"sdk/"$2"/"$3"/bin/current" ]; then
        printf $current$3$end"  "
        return 0
    fi
    if [ -d $basePath"sdk/"$2"/"$3 ]; then
        printf $exist$3$end"  "
        return 0
    fi
    printf $3"  "
}
showOneSdk(){
    sdkName=$2
    sdkVersion=$3
    printf "\033[1;34m%-15s$end " "$sdkName"
    if [ $1"z" = "0z" ];then
        printf "\033[0;35m %-30s  \033[1;31m%-10s$end" "$sdkUrl" "$sdkInfo" 
    fi
    printf "\n    "
    for version in $sdkVersion; do
        querySDKExist $sdkName $version
    done
    printf "\n"
}
# 列出所有可安装的sdk以及状态
listAllSdk(){
    lineNum=`cat $configPath | wc -l ` # 比真实行数少一行
    # nl 然后grep 进行指定的list
    # 目前就是按行号来进行确实配置的, 但是这样就导致了文件过长,拖慢了速度
    i=1
    while [ "$i" -le $lineNum ];do
        sdkName=`sed -n $i','$(($i))'p' $configPath` # 值的格式为 #空格sdkname
        sdkInfo=`sed -n $(($i+1))','$(($i+1))'p' $configPath`
        sdkUrl=`sed -n $(($i+2))','$(($i+2))'p' $configPath`
        sdkVersion=`sed -n $(($i+3))','$(($i+3))'p' $configPath`
        
        # $2 没有值,就只会跑第一个 列出所有
        if [ "# "$2 = "# " ];then
            showOneSdk $1 "$sdkName" "$sdkVersion"
        # 展示具体的sdk版本信息
        elif [ "# "$2 = "$sdkName" ];then
            showOneSdk $1 "$sdkName" "$sdkVersion"
        fi
        i=$(($i+5))
    done
}
###########################################################################################
# 将七牛云放在用户的配置文件中
initQiNiu(){
    if [ ! -f $secretPath ]; then
        printf $error"    请配置七牛云的域名!!\n"$end
        exit
    fi
    . $secretPath
}
# 只是根据URL下载文件到对应位置
downloadZip(){
    url=$1
    sdk=$2
    version=$3
    checkExist $sdk  $version
    if [ ! -d $basePath"zip/"$sdk ]; then
        mkdir $basePath"zip/"$sdk
    fi
    if [ ! -d $basePath"sdk/"$sdk ]; then
        mkdir $basePath"sdk/"$sdk
    fi
    echo $basePath"zip/"$sdk"/"$version".zip"
    if [ ! -f $basePath"zip/"$sdk"/"$version".zip" ]; then
        # curl -o $basePath"zip/"$sdk"/"$version".zip "$url
        touch $basePath"zip/"$sdk"/"$version".zip"
        return 0
    fi
    printf "该SDK的该版本已经下载过\n"
}
# 检查配置文件中是否有该sdk以及version, 返回1则是有 0反之
checkExist(){
    result=`cat -n $configPath | grep "# $1$"`
    for i in $result
    do
        versions=`sed -n $(($i+3))','$(($i+3))'p' $configPath`
        for version in $versions
        do
            if [ "$version" = "$2" ];then 
                return 1
            fi 
        done 
        printf $error"仓库没有该sdk或者该版本\n"$end
        exit
    done
}
# 从七牛云上下载文件
downByQiNiu(){
    initQiNiu
    sdk=$1
    version=$2
    downloadZip $domain$sdk"-"$version".zip" $sdk $version
}
##############################################################################
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