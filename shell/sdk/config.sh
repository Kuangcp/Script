#!/bin/dash

# 配置文件严格格式, 一个sdk四行配置(每一行行首都不能有空格)
# SDK之间只有一行空行分隔, sdk名字后不能有空格 sdk版本之间用空格分隔
# 压缩包之间

jsonUrl='https://raw.githubusercontent.com/Kuangcp/Script/master/shell/sdk/sdks.md'

# githubUrl='https://raw.githubusercontent.com/kuangcp/Apps/master/zip/'
userDir=`cd && pwd`
basePath=$userDir'/.mythsdk'
configPath=$basePath'/sdks.md'
secretPath=$basePath'/secret.conf'

error='\033[1;31m'
current='\033[0;31m'
exist='\033[1;32m'
yellow='\033[1;33m'
end='\033[0m'

shellType='zsh' # shell类别
trueFile=$userDir'/.path' # 如果为空则放在 shell的 .rc 文件中, 不为空就是实际的位置

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
    createDir $basePath"/zip"
    createDir $basePath"/sdk"
    if [ ! -f $configPath ];then
        updateConfig
    fi
}
# .bashrc/.zshrc 文件追加 环境变量 信息
appendPath(){
    sdk=$1
    
    if [ "$trueFile"z = "z" ];then
        trueFile=$userDir"/."$shellType"rc"
    fi

    echo $sdk"_HOME="$basePath"/sdk/"$sdk"/current" >> $trueFile
    if [ $sdk = 'java' ];then
        echo 'export JRE_HOME=${'$sdk'_HOME}/jre \n export CLASSPATH=.:${'$sdk'_HOME}/lib:${JRE_HOME}/lib \n export PATH=${'$sdk'_HOME}/bin:$PATH'  >> $trueFile
    else
        echo "export PATH=\$PATH:$"$sdk"_HOME/bin" >> $trueFile
    fi
    . $trueFile
    printf "环境变量配置完成\n"
}
# 因为sdk 是#后有空格, 所以导致了三个参数进来, 恰巧这个空格省去了我切分出sdk的名字
# 查询sdk是否有对应版本的目录, 有就说明下载了, 如果bin目录下有current文件,说明正在使用
querySDKExist(){
    if [ -f $basePath"/sdk/"$2"/"$3"/bin/current" ]; then
        printf $current$3$end"  "
        return 0
    fi
    if [ -d $basePath"/sdk/"$2"/"$3 ]; then
        printf $exist$3$end"  "
        return 0
    fi
    printf $3"  "
}
showOneSdk(){
    sdkName=$2;sdkVersion=$3;
    short=`echo $sdkName | colrm 1 2`
    printf "\033[1;33m→\033[0;36m%-15s$end " " $short"
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