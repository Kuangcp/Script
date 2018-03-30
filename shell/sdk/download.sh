#!/bin/dash

# 将七牛云放在用户的配置文件中
initQiNiu(){
    if [ ! -f $secretPath ]; then
        printf $error"    请配置七牛云的域名!!\n"$end
        exit
    fi
    . $secretPath
}
# 检查配置文件中是否有该sdk以及version, 返回1则是有 0反之
checkExist(){
    result=`cat -n $configPath | grep "# $1$"`
    for i in $result; do
        versions=`sed -n $(($i+3))','$(($i+3))'p' $configPath`
        for version in $versions; do
            if [ "$version" = "$2" ];then 
                return 1
            fi 
        done 
        printf $error"配置文件中没有该sdk或者该版本\n"$end
        exit
    done
}
# 只是根据URL下载文件到对应位置
downloadZip(){
    url=$1;sdk=$2;version=$3;

    checkExist $sdk  $version
    if [ ! -d $basePath"zip/"$sdk ]; then
        mkdir $basePath"zip/"$sdk
    fi
    if [ ! -d $basePath"sdk/"$sdk ]; then
        mkdir $basePath"sdk/"$sdk
    fi
    echo $basePath"zip/"$sdk"/"$version".zip"
    if [ ! -f $basePath"zip/"$sdk"/"$version".zip" ]; then
        # wget $url -O $basePath"zip/"$sdk"/"$version".zip" 

        # curl -o $basePath"zip/"$sdk"/"$version".zip "$url
        decompression $sdk $version
        return 0
    fi
    decompression $sdk $version
    printf "该SDK的该版本已经下载过\n"
}
# 解压文件
decompression(){
    sdk=$1;version=$2;
    unzip -q $basePath/zip/$sdk/$version.zip -d $basePath/sdk/$sdk
    # 表明第一次安装, 需要配置一些东西
    if [ ! -f $basePath/sdk/$sdk/current ];then
        ln -s $basePath/sdk/$sdk/$version $basePath/sdk/$sdk/current
        touch $basePath/sdk/$sdk/$version/bin/current
        # TODO 配置环境变量
    else
        # TODO 一样的询问
    fi

    printf "解压完成\n"

}
# 从七牛云上下载文件
downByQiNiu(){
    initQiNiu
    sdk=$1;version=$2

    downloadZip $domain$sdk"-"$version".zip" $sdk $version
    

}