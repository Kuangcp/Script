#!/bin/dash

# 将七牛云放在用户的配置文件中
initQiNiu(){
    if [ ! -f $secretPath ]; then
        printf $error"    请配置七牛云的域名!!\n"$end
        exit 0
    fi
    . $secretPath
}
# 检查配置文件中是否有该sdk以及version, 返回1则是有 0反之
checkExist(){
    sdk=$1;version=$2;
    result=`cat -n $configPath | grep "# $sdk$"`
    for i in $result; do
        versions=`sed -n $(($i+3))','$(($i+3))'p' $configPath`
        for j in $versions; do
            if [ "$j" = "$version" ];then 
                return 1
            fi 
        done 
        printf $error"配置文件 $configPath 中没有该版本\n"$end
        exit 0
    done
    printf $error"配置文件 $configPath 中没有该sdk\n"$end
    exit 0
}

# 根据压缩文件进行配置, 不依赖网络
handleLocalZip(){
    sdk=$1;version=$2;zipFile=$3;
    createDir $basePath"/zip/"$sdk
    createDir $basePath"/sdk/"$sdk
    if [ ! -f $basePath"/zip/"$sdk"/"$version".zip" ]; then
        cp `pwd`/$zipFile $basePath"/zip/"$sdk"/"$version".zip" 
    fi
    normalizeLinkFile $sdk $version
}
# 只是根据URL下载文件到对应位置
downloadZip(){
    url=$1;sdk=$2;version=$3;

    checkExist $sdk  $version
    createDir $basePath"/zip/"$sdk
    createDir $basePath"/sdk/"$sdk
    echo "准备下载 "$basePath"/zip/"$sdk"/"$version".zip"
    if [ ! -f $basePath"/zip/"$sdk"/"$version".zip" ]; then
        wget $url -O $basePath"/zip/"$sdk"/"$version".zip" 
        # curl -o $basePath"zip/"$sdk"/"$version".zip "$url
    fi
    normalizeLinkFile $sdk $version
}
normalizeLinkFile(){
    sdk=$1;version=$2;
    if [ -d $basePath/sdk/$sdk/$version ];then
        printf $error"已经解压配置好 $sdk  $version\n"$end
        if [ ! -L $basePath/sdk/$sdk/current ];then 
        printf $green"修复软链接\n"$end
            ln -s $basePath/sdk/$sdk/$version $basePath/sdk/$sdk/current
        fi
        exit 0
    else
        printf "压缩包已存在\n"
        decompression $sdk $version
    fi
}

# 解压文件
decompression(){
    sdk=$1;version=$2;
    if [ ! -f $basePath/zip/$sdk/$version.zip ];then
        printf $error"压缩包不存在, 请进行下载\n"$end
        exit 0
    fi
    size=`du $basePath/zip/$sdk/$version.zip | colrm 8`
    # 小于1000kb的就认为是不完整的zip
    if [ $size -lt 500 ];then
        printf $error"压缩包不完整\n"$end
        rm $basePath/zip/$sdk/$version.zip
        exit 0
    fi
    unzip -q $basePath/zip/$sdk/$version.zip -d $basePath/sdk/$sdk
    # 表明第一次安装, 需要配置一些东西
    if [ ! -L $basePath/sdk/$sdk/current ];then
        printf "首次下载该sdk"
        ln -s $basePath/sdk/$sdk/$version $basePath/sdk/$sdk/current
        touch $basePath/sdk/$sdk/$version/bin/current
        appendPath $sdk
    else
        printf "需要将"$sdk"-"$version" 设置为 "$sdk" 的默认版本吗? [y/n] " 
        read answer
        if [ "$answer"z = "yz" ]; then 
            changeVersion $sdk $version
        fi
    fi
    printf "解压完成\n"
}

# 更改sdk使用的版本
changeVersion(){
    sdk=$1;version=$2;
    checkExist $sdk $version
    
    if [ ! -d $basePath/sdk/$sdk/$version ];then 
        decompression $sdk $version
    fi
    printf "更改"$sdk" 版本为 "$version"\n"
    if [ -L $basePath/sdk/$sdk/current ];then
        rm $basePath/sdk/$sdk/current/bin/current
        rm $basePath/sdk/$sdk/current
        ln -s $basePath/sdk/$sdk/$version $basePath/sdk/$sdk/current
        touch $basePath/sdk/$sdk/$version/bin/current
    fi
}

# 从七牛云上下载文件
downByQiNiu(){
    initQiNiu
    sdk=$1;version=$2;
    downloadZip $domain$sdk"-"$version".zip" $sdk $version
}